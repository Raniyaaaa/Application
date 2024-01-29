import 'package:flutter/material.dart';
import 'package:shopping_cart_app/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start the animation when the splash screen is displayed
    _controller.forward();

    // After 2 seconds, navigate to another page
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            color: Color.fromRGBO(
                255, 251, 187, _animation.value), // Adjust color as needed
            child: Center(
              child: Opacity(
                opacity: _animation.value,
                child: Image.network(
                  'https://i.pinimg.com/originals/07/64/e5/0764e58ab3cc673d69f0cf5dd93418de.gif', // Replace with your actual image URL
                  width: 300.0,
                  height: 300.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
