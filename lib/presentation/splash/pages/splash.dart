import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_clone/core/configs/assets/app_vectors.dart';
import 'package:spotify_clone/domain/repository/auth/auth.dart';
import 'package:spotify_clone/presentation/auth/pages/signup_or_siginin.dart';
import 'package:spotify_clone/presentation/home/pages/home.dart';
import 'package:spotify_clone/service_locator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _overlayController;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        _overlayController.forward();
      },
    );

    redirect();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.36, 0), end: Offset.zero).animate(_overlayController),
              child: SvgPicture.asset(AppVectors.logo),
            ),
            SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0.73, 0), end: const Offset(2, 0)).animate(_overlayController),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 100,
                width: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            var result = sl<AuthRepository>().checkUserAuthState();
            bool userLoggedIn = result.fold(
              (l) {
                //User not logged in or fetch error
                return false;
              },
              (r) {
                //User logged in
                return true;
              },
            ); //Default Route
            return userLoggedIn? const HomePage() :const SignupOrSigninPage();
          },
        ),
      );
    }
  }
}
