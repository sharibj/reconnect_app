import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 60,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = SvgPicture.asset(
      'assets/images/logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (showShadow) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: logo,
      );
    }

    return logo;
  }
}