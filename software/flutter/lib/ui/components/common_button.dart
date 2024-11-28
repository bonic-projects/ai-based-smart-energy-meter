import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onpress;
  const CommonButton({required this.text, required this.onpress, super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onpress,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black12,
        side: BorderSide(color: Colors.white38)

      ),
    );
  }
}
