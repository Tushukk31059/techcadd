// lib/models/staff_models.dart
import 'dart:ui';

import 'package:flutter/material.dart';
// Make sure your StaffProfile has all these fields
class StaffProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String department;
  final String phone;
  final String address;
  final bool isActive;
  final DateTime? dateJoined;
  final DateTime? lastLogin;

  StaffProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.department,
    required this.phone,
    required this.address,
    required this.isActive,
    this.dateJoined,
    this.lastLogin,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) {
    return StaffProfile(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isActive: json['is_active'] ?? false,
      dateJoined: json['date_joined'] != null 
          ? DateTime.parse(json['date_joined'].toString().replaceAll('Z', ''))
          : null,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'].toString().replaceAll('Z', ''))
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
  String get status => isActive ? 'Active' : 'Inactive';
  Color get statusColor => isActive ? Colors.green : Colors.red;
}
class CreateStaffRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String department;
  final String phone;
  final String address;

  CreateStaffRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.department,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'department': department,
      'phone': phone,
      'address': address,
    };
  }
}

class StaffListResponse {
  final int staffCount;
  final List<StaffProfile> staffList;

  StaffListResponse({
    required this.staffCount,
    required this.staffList,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    return StaffListResponse(
      staffCount: json['staff_count'] ?? 0,
      staffList: (json['staff_list'] as List<dynamic>)
          .map((staff) => StaffProfile.fromJson(staff))
          .toList(),
    );
  }
}