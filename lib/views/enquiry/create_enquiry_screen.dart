import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/dropdown_models.dart';


class CreateEnquiryScreen extends StatefulWidget {
  final DropdownChoices dropdownChoices;
  final VoidCallback onEnquiryCreated;

  const CreateEnquiryScreen({
    super.key,
    required this.dropdownChoices,
    required this.onEnquiryCreated,
  });

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _workCollegeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _nextFollowUpController = TextEditingController();

    String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatCourseName(String course) {
    // Handle common course name formatting
    final formatted = course.replaceAll('_', ' ');
    return _capitalizeWords(formatted);
  }

  String _formatStatus(String status) {
    // Handle status formatting
    final formatted = status.replaceAll('_', ' ');
    return _capitalizeWords(formatted);
  }

  // Text Input Formatters
  final TextInputFormatter _nameFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      
      // Capitalize first letter of each word
      final words = newValue.text.split(' ');
      final capitalizedWords = words.map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).toList();
      
      final capitalizedText = capitalizedWords.join(' ');
      
      return TextEditingValue(
        text: capitalizedText,
        selection: newValue.selection,
      );
    },
  );

  final TextInputFormatter _sentenceFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      
      // Capitalize first letter only
      final text = newValue.text;
      final capitalizedText = text[0].toUpperCase() + text.substring(1);
      
      return TextEditingValue(
        text: capitalizedText,
        selection: newValue.selection,
      );
    },
  );

  String? _selectedCentre;
  String? _selectedTrade;
  String? _selectedSource;
  String? _selectedStatus;
  bool _isSubmitting = false;

  // Date picker methods
  Future<void> _selectDate(TextEditingController controller, String fieldName) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF282C5C),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
    }
  }

  // Input decoration with new design
  InputDecoration _decoration({
    String? hintText,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF282C5C), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    );
  }

  // Validators
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return !regex.hasMatch(v) ? 'Enter a valid email' : null;
  }

  String? _mobileValidator(String? v) {
    if (v == null || v.isEmpty) return 'Mobile number is required';
    if (v.length != 10) return 'Please enter a 10-digit mobile number';
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isDateField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: isDateField,
          onTap: isDateField ? () => _selectDate(controller, label) : null,
          decoration: _decoration(
            hintText: hintText,
            prefix: Icon(icon, color: const Color(0xFF282C5C)),
            suffix: isDateField
                ? const Icon(Icons.calendar_today, color: Color(0xFF282C5C))
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownChoice> items,
    required Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((DropdownChoice item) {
            return DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.label),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired ? (v) => v == null ? "This field is required" : null : null,
          decoration: _decoration(
            prefix: Icon(icon, color: const Color(0xFF282C5C)),
          ).copyWith(hintText: 'Select $label'),
        ),
      ],
    );
  }
Future<void> _submitEnquiry() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    // FORMAT DATA BEFORE SENDING
    final enquiryData = {
      'student_name': _capitalizeWords(_nameController.text.trim()),
      'date_of_birth': _dobController.text.trim(),
      'qualification': _capitalizeWords(_qualificationController.text.trim()),
      'work_college': _workCollegeController.text.isEmpty 
          ? "" 
          : _capitalizeWords(_workCollegeController.text.trim()),
      'mobile': _phoneController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'address': _capitalizeFirstLetter(_addressController.text.trim()),
      'centre': _selectedCentre,
      'trade': _selectedTrade, // Backend will handle display values
      'enquiry_source': _selectedSource, // Backend will handle display values
      'enquiry_status': _selectedStatus, // Backend will handle display values
      'remark': _remarkController.text.isEmpty 
          ? "" 
          : _capitalizeFirstLetter(_remarkController.text.trim()),
      'next_follow_up_date': _nextFollowUpController.text.isEmpty 
          ? "" 
          : _nextFollowUpController.text.trim(),
    };

    print('📤 Sending formatted enquiry data: $enquiryData');
    
    await ApiService.createEnquiry(enquiryData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enquiry created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    widget.onEnquiryCreated();
    Navigator.pop(context);
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create enquiry: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isSubmitting = false);
  }
}  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _workCollegeController.dispose();
    _dobController.dispose();
    _remarkController.dispose();
    _nextFollowUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282C5C),
        title: const Text(
          "Create New Enquiry",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Form Header
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Fill out the enquiry form',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Information Section
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _nameController,
                    label: "Student Name",
                    hintText: 'Enter Student Name',
                    icon: Icons.person,
                    validator: _required,
                    
  inputFormatters: [_nameFormatter],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _dobController,
                    label: "Date of Birth",
                    hintText: 'Select Date of Birth',
                    icon: Icons.cake,
                    isDateField: true,
                    validator: _required,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _qualificationController,
                    label: "Qualification",
                    hintText: 'Enter Qualification',
                    icon: Icons.school,
                    validator: _required,
  inputFormatters: [_nameFormatter],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _workCollegeController,
                    label: "Work/College (Optional)",
                    hintText: 'Enter Work or College',
                    icon: Icons.work,
  inputFormatters: [_nameFormatter],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _phoneController,
                    label: "Mobile Number",
                    icon: Icons.phone,
                    hintText: 'Enter Mobile Number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: _mobileValidator,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    hintText: 'Enter Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _addressController,
                    label: "Address",
                    hintText: 'Enter Complete Address',
                    icon: Icons.location_on,
                    validator: _required,
  inputFormatters: [_sentenceFormatter],
                  ),
                  const SizedBox(height: 24),

                  // Enquiry Details Section
                  const Text(
                    'Enquiry Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Centre",
                    icon: Icons.business,
                    value: _selectedCentre,
                    items: widget.dropdownChoices.centreChoices,
                    onChanged: (v) => setState(() => _selectedCentre = v),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Course/Trade",
                    icon: Icons.school,
                    value: _selectedTrade,
                    items: widget.dropdownChoices.tradeChoices,
                    onChanged: (v) => setState(() => _selectedTrade = v),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Enquiry Source",
                    icon: Icons.source,
                    value: _selectedSource,
                    items: widget.dropdownChoices.enquirySourceChoices,
                    onChanged: (v) => setState(() => _selectedSource = v),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Enquiry Status",
                    icon: Icons.timeline,
                    value: _selectedStatus,
                    items: widget.dropdownChoices.enquiryStatusChoices,
                    onChanged: (v) => setState(() => _selectedStatus = v),
                  ),
                  const SizedBox(height: 24),

                  // Additional Information Section
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _remarkController,
                    label: "Remarks (Optional)",
                    hintText: 'Enter any remarks or notes',
                    icon: Icons.note,
  inputFormatters: [_sentenceFormatter],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _nextFollowUpController,
                    label: "Next Follow Up Date (Optional)",
                    hintText: 'Select Follow Up Date',
                    icon: Icons.calendar_today,
                    isDateField: true,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            _isSubmitting ? "Creating..." : "Create Enquiry",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitEnquiry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF282C5C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}