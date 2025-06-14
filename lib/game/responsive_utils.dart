import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double dialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 500) return width * 0.95;
    if (width < 800) return width * 0.8;
    return 420;
  }

  static double dialogHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height < 600) return height * 0.8;
    return 400;
  }
}
