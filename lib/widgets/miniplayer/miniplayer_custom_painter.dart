// import 'package:flutter/material.dart';

// class MiniplayerCustomPainter extends CustomPainter{
// final int activeIndex;
// final int totalTabs;

// MiniplayerCustomPainter({required this.activeIndex, required this.totalTabs});

// @override
// void paint(Canvas canvas, Size size) {
//   Paint paint = Paint()
//   ..color = Color(0xff00BCE5)
//   ..style = PaintingStyle.fill;

//   Path path = Path();
//   double tabWidth = size.width / totalTabs;

//   double startX = activeIndex * tabWidth;
//   double endX = startX + tabWidth;

//   double mainPlayerHeight = size.height - 40;

//   path.moveTo(12, 0);
//   path.lineTo(startX - 12, 0);

//   path.lineTo(startX, 0);
//   path.lineTo(startX, size.height - 12);
//   path.lineTo(endX, size.height - 12);
//   path.lineTo(endX, 0);

//   path.lineTo(size.width - 12, 0);
//   path.lineTo(size.width, mainPlayerHeight);
//   path.lineTo(0, mainPlayerHeight);

//   path.close();
//   canvas.drawPath(path, paint);
// }

// @override
// bool shouldRepaint(covariant MiniplayerCustomPainter oldDelegate) {
//   return oldDelegate.activeIndex != activeIndex;
// }

// }