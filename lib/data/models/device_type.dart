import 'package:flutter/material.dart';

class DeviceType {
  final String slug;
  final String singularName;
  final String pluralName;
  final IconData icon;

  DeviceType(
      {required this.slug,
      required this.singularName,
      required this.pluralName,
      required this.icon});
}
