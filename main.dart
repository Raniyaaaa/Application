import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shopping_cart_app/ss.dart';

void main() {
  runApp(MyApp());
}

class Product {
  final String name;
  final int id;
  final double cost;
  int availability;
  final String details;
  final String category;
  int quantity;

  Product({
    required this.name,
    required this.id,
    required this.cost,
    required this.availability,
    required this.details,
    required this.category,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      id: json['id'],
      cost: json['cost'],
      availability: json['availability'],
      details: json['details'],
      category: json['category'],
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'cost': cost,
      'availability': availability,
      'details': details,
      'category': category,
      'quantity': quantity,
    };
  }
}

// code to Read the JSON text from an external file dynamically rather hardcoding it.
class AlternateProductService {
  static Future<List<Product>> getProducts() async {
    // Load JSON file from assets
    String jsonString = await rootBundle.loadString('assets/products.json');

    // Parse JSON
    List<dynamic> jsonList = json.decode(jsonString);
    List<Product> products =
        jsonList.map((json) => Product.fromJson(json)).toList();

    return products;
  }
}

// code to
/*class ProductService {
  static Future<List<Product>> getProducts() async {
    // Fetch JSON from an external file or API
    String jsonString = '''
    [
      {
        "name": "Apple",
        "id": 1,
        "cost": 30.0,
        "availability": 5,
        "details": "Imported from Swiss",
        "category": "Premium",
        "quantity": 0
      },
      {
        "name": "Mango",
        "id": 2,
        "cost": 50.0,
        "availability": 8,
        "details": "Farmed at Selam",
        "category": "Tamilnadu",
        "quantity": 0
      },
      {
        "name": "Banana",
        "id": 3,
        "cost": 5.0,
        "availability": 10,
        "details": "",
        "category": "",
        "quantity": 0
      },
      {
        "name": "Orange",
        "id": 4,
        "cost": 25.0,
        "availability": 3,
        "details": "from Nagpur",
        "category": "Premium",
        "quantity": 0
      }
    ]
    ''';

    List<dynamic> jsonList = json.decode(jsonString);
    List<Product> products =
        jsonList.map((json) => Product.fromJson(json)).toList();

    return products;
  }

  /*static Future<List<Product>> getProductsByCategory(String category) async {
    List<Product> allProducts = await getProducts();
    return allProducts
        .where((product) => product.category == category)
        .toList();
  }*/
  
}*/
class ProductService {
  static Future<List<Product>> getProducts() async {
    String jsonString = await rootBundle.loadString('assets/products.json');
    List<dynamic> jsonList = json.decode(jsonString);
    List<Product> products =
        jsonList.map((json) => Product.fromJson(json)).toList();
    return products;
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    List<Product> allProducts = await getProducts();
    return allProducts
        .where((product) => product.category == category)
        .toList();
  }
}

class CartService {
  static List<Product> cartItems = [];

  static void addToCart(Product product) {
    if (product.availability > 0 && product.quantity > 0) {
      Product productCopy = Product(
        name: product.name,
        id: product.id,
        cost: product.cost,
        availability: product.availability,
        details: product.details,
        category: product.category,
        quantity: product.quantity,
      );

      productCopy.availability -= product.quantity;

      cartItems.add(productCopy);
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor customPrimarySwatch =
        createMaterialColor(Color(0xFFFFFCBF)); // Use the specified RGB values

    return MaterialApp(
      title: 'Shopping Cart App',
      theme: ThemeData(
        primarySwatch: customPrimarySwatch,
      ),
      home: SplashScreen(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};

    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Product> products = [];
  String? selectedCategory;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  _loadProducts() async {
    products = await ProductService.getProducts();
    setState(() {});
  }

  void _filterProducts() async {
    if (selectedCategory == 'Default') {
      selectedCategory = null;
    }

    List<Product> filteredProducts = selectedCategory != null
        ? await ProductService.getProductsByCategory(selectedCategory!)
        : await ProductService.getProducts();

    setState(() {
      products = filteredProducts;
    });
  }

  _openDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedQuantity = quantity;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(product.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Details: ${product.details}\nCost: \Rs. ${product.cost}'),
                  SizedBox(height: 10),
                  Text('Select Quantity:'),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (selectedQuantity > 1) {
                              selectedQuantity--;
                            }
                          });
                        },
                      ),
                      Text('$selectedQuantity'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            selectedQuantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black, // Change the text color
                  ),
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedQuantity <= product.availability) {
                      int index = products.indexOf(product);
                      if (index != -1) {
                        setState(() {
                          products[index].availability -= selectedQuantity;
                          products[index].quantity = selectedQuantity;
                        });
                      }

                      CartService.addToCart(product);

                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Not enough availability for the selected quantity.'),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black, // Change the text color
                  ),
                  child: Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedItemsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart App'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            hint: Text('Select Category'),
            onChanged: (String? value) {
              setState(() {
                selectedCategory = value;
                _filterProducts();
              });
            },
            items: <String>['Default', 'Premium', 'Tamilnadu']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      'Category: ${product.category}\nAvailability: ${product.availability}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _openDialog(product);
                    },
                    child: Text('View Details'),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 50),
          Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              onPressed: _proceed,
              child: Text('PROCEED'),
            ),
          ),
        ],
      ),
    );
  }
}

// CODE FOR SELECTED ITEM SCREEN
class SelectedItemsScreen extends StatelessWidget {
  _checkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThankYouScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCost = CartService.cartItems
        .fold(0, (sum, product) => sum + (product.cost * product.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text('SELECTED ITEMS'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'SELECTED ITEMS AND QUANTITIES:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: CartService.cartItems.length,
              itemBuilder: (context, index) {
                Product product = CartService.cartItems[index];
                return ListTile(
                  title: Text('${product.name} x ${product.quantity}'),
                  subtitle: Text('Category: ${product.category}'),
                );
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(75.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'TOTAL COST:  \Rs. ${totalCost.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () => _checkout(context),
              child: Text('CHECK OUT'),
            ),
          )
        ],
      ),
    );
  }
}

// CODE FOR THANK YOU SCREEN
class ThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: null, // Add an icon to the app bar
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.thumb_up,
              size: 100.0,
              color: Color.fromRGBO(196, 194, 145, 1),
            ),
            SizedBox(height: 20.0),
            Text(
              'Thank You for Shopping!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
