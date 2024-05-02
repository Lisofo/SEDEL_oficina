import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget? child;
  
  const CustomContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.primary, width: 15))
      ),
      child: child,
    );
  }
}