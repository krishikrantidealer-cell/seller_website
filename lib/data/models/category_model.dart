import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final int count;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });

  @override
  List<Object?> get props => [id, name, icon, count];
}
