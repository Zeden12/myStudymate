import 'package:flutter/material.dart';

class AppStyles {
  static const double cardPadding = 16.0;

  static const cardRadius = BorderRadius.all(Radius.circular(16));
  static const cardElevation = 2.0;

  static const subjectTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const dateTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const chipTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const statusColors = {
    'Individual': Colors.green,
    'Group': Colors.blue,
  };

  static const deadlineColor = Colors.redAccent;
}
