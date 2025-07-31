import 'package:flutter/material.dart';

class JobImagePlaceholders {
  static const Map<String, IconData> categoryIcons = {
    'Transport': Icons.local_shipping,
    'Cleaning': Icons.cleaning_services,
    'Events': Icons.event,
    'Construction': Icons.construction,
    'Delivery': Icons.delivery_dining,
  };

  static Widget getJobImage(String? imagePath, String? category) {
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(category);
        },
      );
    }
    return _buildPlaceholder(category);
  }

  static Widget _buildPlaceholder(String? category) {
    IconData iconData = categoryIcons[category ?? ''] ?? Icons.work;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: Colors.green,
        size: 24,
      ),
    );
  }

  static Widget getLargeJobImage(String? imagePath, String? category) {
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildLargePlaceholder(category);
        },
      );
    }
    return _buildLargePlaceholder(category);
  }

  static Widget _buildLargePlaceholder(String? category) {
    IconData iconData = categoryIcons[category ?? ''] ?? Icons.work;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        iconData,
        color: Colors.green,
        size: 48,
      ),
    );
  }
} 