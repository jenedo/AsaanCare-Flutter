import 'package:flutter/material.dart';

class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconAsset,
    required this.iconColor,
    required this.isConnected,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String? subtitle;
  final String iconAsset;
  final Color iconColor;
  final bool isConnected;
  bool isSelected;
}
