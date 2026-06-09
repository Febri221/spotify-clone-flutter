import 'package:flutter/material.dart';

class LibraryItemModel {
  final String title;
  final String subtitle;
  final Color titleColor;
  final String? imagePath;
  final Widget iconInContainer;
  final Gradient? containerGradient;
  final Color? containerColor;
  final String? category;
  bool isPinned;

  LibraryItemModel({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    this.imagePath,
    required this.iconInContainer,
    this.containerGradient,
    this.containerColor,
    this.category,
    this.isPinned = false,
  });
}