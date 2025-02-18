import 'package:flutter/material.dart';

class TopEnergyAlert extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const TopEnergyAlert({
    required this.message,
    required this.onDismiss,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
