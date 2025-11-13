// lib/screens/create_staff_screen.dart
import 'package:flutter/material.dart';

import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/staff_model.dart';


class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedRole = 'trainer';
  String _selectedDepartment = 'training';
  
  bool _isLoading = false;
  String _errorMessage = '';

  // Available options for dropdowns
final List<String> _roles = [
  'trainer',      
  'counselor',      
  'manager'       
];
  
  final List<String> _departments = [
    'training',
    'admissions',
    'administration',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createStaffAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final staffData = CreateStaffRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole,
        department: _selectedDepartment,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      final response = await ApiService.createStaffAccount(staffData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Staff account created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form and go back
      _formKey.currentState!.reset();
      Navigator.pop(context);
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create staff: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Staff Account'),
        backgroundColor: const Color(0xFF282C5C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red[400]),
                        onPressed: () => setState(() => _errorMessage = ''),
                      ),
                    ],
                  ),
                ),

              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildNameTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hintText: 'Enter first name',
                      // icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNameTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hintText: 'Enter last name',
                      // icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Login Credentials Section
              _buildSectionHeader('Login Credentials'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hintText: 'Enter username',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter password',
                icon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role and Department Section
              _buildSectionHeader('Staff Details'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedRole,
                      label: 'Role',
                      items: _roles,
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedDepartment,
                      label: 'Department',
                      items: _departments,
                      onChanged: (value) {
                        setState(() => _selectedDepartment = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                hintText: 'Enter full address',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _createStaffAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF282C5C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Staff Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF282C5C),
      ),
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16, 
            ),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: const Color(0xFF282C5C)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            isDense: true, 
            alignLabelWithHint: true,
          ),
          style: const TextStyle(
            fontSize: 16,
            height: 1.0, 
          ),
        ),
      ),
    ],
  );
}

Widget _buildNameTextField({
  required TextEditingController controller,
  required String label,
  required String hintText,
  
  bool isPassword = false,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16, 
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16, 
            ),
            isDense: true, 
            alignLabelWithHint: true,
          ),
          style: const TextStyle(
            fontSize: 16,
            height: 1.0, 
          ),
        ),
      ),
    ],
  );
}


Widget _buildDropdown({
  required String value,
  required String label,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  
  final Map<String, String> roleLabels = {
    'trainer': 'Trainer',
    'counselor': 'Counselor', 
    'manager': 'Manager'
  };
  
  
  final Map<String, String> departmentLabels = {
    'training': 'Training',
    'admissions': 'Admissions', 
    'administration': 'Administration'
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(
              label == 'Role' ? Icons.work : Icons.business,
              color: const Color(0xFF282C5C),
            ),
          ),
          items: items.map((String item) {
            
            String displayText = item;
            if (label == 'Role') {
              displayText = roleLabels[item] ?? item;
            } else if (label == 'Department') {
              displayText = departmentLabels[item] ?? item;
            }
            
            return DropdownMenuItem<String>(
              value: item, 
              child: Text(displayText), 
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}
}