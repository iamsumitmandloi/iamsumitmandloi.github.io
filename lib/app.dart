import 'package:flutter/material.dart';
import 'package:app/utilities/app_constants.dart';
import 'package:app/landing/landing_screen.dart';
import 'package:responsive_framework/responsive_framework.dart';

// Screen-width ranges. Ends sit just below the next start so every width,
// fractional ones included, falls in exactly one range.
const _breakpoints = [
  Breakpoint(start: 0, end: 449.999),
  Breakpoint(start: 450, end: 799.999, name: MOBILE),
  Breakpoint(start: 800, end: 1199.999, name: TABLET),
  Breakpoint(start: 1200, end: double.infinity, name: DESKTOP),
];

// Width the layout is laid out at before being scaled to fit the screen.
// Phones and small tablets get a 450 wide layout, tablets an 800 wide one,
// and desktops are laid out at their real width.
double? _layoutWidth(double screenWidth) {
  if (screenWidth >= 1200) return null;
  if (screenWidth >= 800) return 800;
  if (screenWidth >= 300) return 450;
  return 300;
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,

      // Initializing responsive_framework here.
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          breakpoints: _breakpoints,
          child: Builder(
            builder: (context) {
              return ColoredBox(
                color: primaryColor,
                child: ResponsiveScaledBox(
                  width: _layoutWidth(MediaQuery.sizeOf(context).width),
                  child: BouncingScrollWrapper.builder(context, child!),
                ),
              );
            },
          ),
        );
      },
      home: const LandingScreen(),
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Ubuntu',
      ),
    );
  }
}
