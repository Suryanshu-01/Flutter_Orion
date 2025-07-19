import 'package:flutter/material.dart';

class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dashboard Icon
          IconButton(
            icon: Icon(
              Icons.dashboard,
              size: 28,
              color: currentIndex == 0 ? Colors.deepPurple : Colors.grey,
            ),
            onPressed: () => onItemTapped(0),
          ),

          // Spacer for center FAB
          const SizedBox(width: 40),

          // Expense Tracker Icon
          IconButton(
            icon: Icon(
              Icons.bar_chart_rounded,
              size: 28,
              color: currentIndex == 1 ? Colors.deepPurple : Colors.grey,
            ),
            onPressed: () => onItemTapped(1),
          ),
        ],
      ),
    );
  }
}
