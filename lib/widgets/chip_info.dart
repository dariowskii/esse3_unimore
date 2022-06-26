import 'package:flutter/material.dart';

/// Chip utilizzata per le info primarie della [HomeScreen].
class ChipInfo extends StatelessWidget {
  /// Testo della chip.
  final String? text;

  /// Grandezza del font della chip.
  final double textSize;

  const ChipInfo({this.text = 'null', this.textSize = 14});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Theme.of(context).primaryColor,
      label: Text(
        text!,
        style: TextStyle(
          color: Colors.white,
          fontSize: textSize,
        ),
      ),
    );
  }
}
