import 'package:flutter/material.dart';

/// Category model representing a task category
///
/// This is a plain Dart class used for SQLite persistence.
/// Use [toMap] to convert for database storage and
/// [fromMap] factory constructor to create from database data.
class Category {
  final String id;
  final String name;
  final int colorValue;
  final int iconCode;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCode,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  /// Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCode': iconCode,
    };
  }

  /// Create Category from SQLite Map data
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['colorValue'] as int,
      iconCode: map['iconCode'] as int,
    );
  }
}
