import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final int selectedCategory;
  final Function(int) onCategorySelected;

   CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // Height container pembungkus di AppBar
      padding: EdgeInsets.only(left: 16, bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == index;
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 150), // Typo microseconds di kode asli gua ganti millis biar animasi jalan bener
              opacity: isSelected ? 1 : 0.7,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: GestureDetector(
                  onTap: () => onCategorySelected(index),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}