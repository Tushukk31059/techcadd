// lib/views/create_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/course_models.dart';
import 'package:techcadd/utils/snackbar_utils.dart';

class CreateRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> registrationOptions;
  final VoidCallback onRegistrationCreated;

  const CreateRegistrationScreen({
    super.key,
    required this.registrationOptions,
    required this.onRegistrationCreated,
  });

  @override
  State<CreateRegistrationScreen> createState() =>
      _CreateRegistrationScreenState();
}

class _CreateRegistrationScreenState extends State<CreateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _workCollegeController = TextEditingController();
  final TextEditingController _contactAddressController =
      TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _whatsappNoController = TextEditingController();
  final TextEditingController _parentsNoController = TextEditingController();

  // Course Information Controllers
  final TextEditingController _softwareCoveredController =
      TextEditingController();
  final TextEditingController _durationHoursController =
      TextEditingController();
  final TextEditingController _totalCourseFeeController =
      TextEditingController();
  final TextEditingController _paidFeeController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();

  // Dropdown Values
  String? _selectedBranch;
  String? _selectedCourseType;
  String? _selectedCourse;
  String? _selectedDuration;

  // Course List
  List<Course> _courses = [];
  bool _isLoadingCourses = false;
  bool _isSubmitting = false;

  // Text Formatting Methods
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  final TextInputFormatter _nameFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

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
  });

  final TextInputFormatter _sentenceFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      final text = newValue.text;
      final capitalizedText = text[0].toUpperCase() + text.substring(1);

      return TextEditingValue(
        text: capitalizedText,
        selection: newValue.selection,
      );
    },
  );

  // Date Picker
  Future<void> _selectDate(
    TextEditingController controller,
    String fieldName,
  ) async {
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
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
    }
  }

  // Load Courses by Course Type
  Future<void> _loadCoursesByType(int courseTypeId) async {
    setState(() => _isLoadingCourses = true);

    try {
      final courses = await ApiService.getCoursesByType(courseTypeId);
      setState(() {
        _courses = courses
            .map((courseJson) => Course.fromJson(courseJson))
            .toList();
        _selectedCourse = null; // Reset course selection
      });
    } catch (e) {
      print('❌ Error loading courses: $e');
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to load course',
      );
    } finally {
      setState(() => _isLoadingCourses = false);
    }
  }

  // Input Decoration
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

  String? _feeValidator(String? v) {
    if (v == null || v.isEmpty) return 'Fee is required';
    if (double.tryParse(v) == null) return 'Enter a valid amount';
    return null;
  }

  // Build TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isDateField = false,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: isRequired ? validator : null,
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

  // Build Dropdown Widget
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<dynamic> items,
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
          items: items.map((item) {
            String itemValue, itemLabel;

            if (item is Map<String, dynamic>) {
              // For course types and duration choices
              itemValue = item['value'] ?? item['id'].toString();
              itemLabel = item['label'] ?? item['name'];
            } else if (item is List) {
              // For branch choices
              itemValue = item[0];
              itemLabel = item[1];
            } else if (item is Course) {
              // For courses
              itemValue = item.id.toString();
              itemLabel = item.name;
            } else {
              itemValue = item.toString();
              itemLabel = item.toString();
            }

            return DropdownMenuItem<String>(
              value: itemValue,
              child: Text(itemLabel),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (v) => v == null ? "This field is required" : null
              : null,
          decoration: _decoration(
            prefix: Icon(icon, color: const Color(0xFF282C5C)),
          ).copyWith(hintText: 'Select $label'),
        ),
      ],
    );
  }

  // Submit Registration
  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate paid fee doesn't exceed total fee
    final totalFee = double.tryParse(_totalCourseFeeController.text) ?? 0;
    final paidFee = double.tryParse(_paidFeeController.text) ?? 0;

    if (paidFee > totalFee) {
      CustomSnackBar.showError(
        context: context,
        message: 'Paid fee cannot exceed total course fee',
      );

      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final registrationData = {
        'branch': _selectedBranch,
        'joining_date': _joiningDateController.text,
        'student_name': _capitalizeWords(_studentNameController.text.trim()),
        'father_name': _capitalizeWords(_fatherNameController.text.trim()),
        'date_of_birth': _dobController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'qualification': _capitalizeWords(_qualificationController.text.trim()),
        'work_college': _workCollegeController.text.isEmpty
            ? ""
            : _capitalizeWords(_workCollegeController.text.trim()),
        'contact_address': _capitalizeFirstLetter(
          _contactAddressController.text.trim(),
        ),
        'phone_no': _phoneNoController.text.trim(),
        'whatsapp_no': _whatsappNoController.text.isEmpty
            ? ""
            : _whatsappNoController.text.trim(),
        'parents_no': _parentsNoController.text.isEmpty
            ? ""
            : _parentsNoController.text.trim(),
        'course_type': _selectedCourseType,
        'course': _selectedCourse,
        'software_covered': _softwareCoveredController.text.isEmpty
            ? ""
            : _softwareCoveredController.text.trim(),
        'duration_months': _selectedDuration,
        'duration_hours': int.tryParse(_durationHoursController.text) ?? 0,
        'total_course_fee': totalFee,
        'paid_fee': paidFee,
      };

      print('📤 Sending registration data: $registrationData');

      final response = await ApiService.createStudentRegistration(
        registrationData,
      );

      CustomSnackBar.showSuccess(
        context: context,
        message: 'Student Registered successfully',
      );

      // Show credentials if available
      final credentials = response['login_credentials'];
      if (credentials != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Student registered successfully with credentials:'),
                const SizedBox(height: 16),
                Text('Username: ${credentials['username']}'),
                Text('Password: ${credentials['password']}'),
                const SizedBox(height: 8),
                const Text(
                  'Please save these credentials securely!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      widget.onRegistrationCreated();
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Student Registration Failed',
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    _workCollegeController.dispose();
    _contactAddressController.dispose();
    _phoneNoController.dispose();
    _whatsappNoController.dispose();
    _parentsNoController.dispose();
    _softwareCoveredController.dispose();
    _durationHoursController.dispose();
    _totalCourseFeeController.dispose();
    _paidFeeController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseTypes = widget.registrationOptions['course_types'] ?? [];
    final durationChoices =
        widget.registrationOptions['duration_choices'] ?? [];
    final branchChoices = widget.registrationOptions['branch_choices'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282C5C),
        title: const Text(
          "Create Student Registration",
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
                      'Fill out the registration form',
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
                    controller: _studentNameController,
                    label: "Student Name",
                    hintText: 'Enter Student Name',
                    icon: Icons.person,
                    validator: _required,
                    inputFormatters: [_nameFormatter],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _fatherNameController,
                    label: "Father's Name",
                    hintText: "Enter Father's Name",
                    icon: Icons.family_restroom,
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
                    controller: _emailController,
                    label: "Email",
                    hintText: 'Enter Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
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
                    isRequired: false,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _contactAddressController,
                    label: "Contact Address",
                    hintText: 'Enter Complete Address',
                    icon: Icons.location_on,
                    validator: _required,
                    inputFormatters: [_sentenceFormatter],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _phoneNoController,
                    label: "Phone Number",
                    hintText: 'Enter Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: _mobileValidator,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _whatsappNoController,
                    label: "WhatsApp Number (Optional)",
                    hintText: 'Enter WhatsApp Number',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    isRequired: false,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _parentsNoController,
                    label: "Parents Number (Optional)",
                    hintText: 'Enter Parents Number',
                    icon: Icons.contact_phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    isRequired: false,
                  ),
                  const SizedBox(height: 24),

                  // Course Information Section
                  const Text(
                    'Course Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Branch",
                    icon: Icons.business,
                    value: _selectedBranch,
                    items: branchChoices,
                    onChanged: (v) => setState(() => _selectedBranch = v),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Course Type",
                    icon: Icons.category,
                    value: _selectedCourseType,
                    items: courseTypes,
                    onChanged: (v) {
                      setState(() => _selectedCourseType = v);
                      if (v != null) {
                        _loadCoursesByType(int.parse(v));
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingCourses)
                    const Column(
                      children: [
                        SizedBox(height: 8),
                        LinearProgressIndicator(),
                        SizedBox(height: 16),
                      ],
                    )
                  else
                    _buildDropdown(
                      label: "Course",
                      icon: Icons.school,
                      value: _selectedCourse,
                      items: _courses,
                      onChanged: (v) => setState(() => _selectedCourse = v),
                    ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Duration",
                    icon: Icons.timer,
                    value: _selectedDuration,
                    items: durationChoices,
                    onChanged: (v) => setState(() => _selectedDuration = v),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _durationHoursController,
                    label: "Duration Hours",
                    hintText: 'Enter total course hours',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _required,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _softwareCoveredController,
                    label: "Software Covered (Optional)",
                    hintText: 'Enter software/tools covered',
                    icon: Icons.computer,
                    isRequired: false,
                  ),
                  const SizedBox(height: 24),

                  // Fee Information Section
                  const Text(
                    'Fee Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _totalCourseFeeController,
                    label: "Total Course Fee",
                    hintText: 'Enter total course fee',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: _feeValidator,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _paidFeeController,
                    label: "Paid Fee",
                    hintText: 'Enter paid fee amount',
                    icon: Icons.payment,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: _feeValidator,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _joiningDateController,
                    label: "Joining Date",
                    hintText: 'Select Joining Date',
                    icon: Icons.calendar_today,
                    isDateField: true,
                    validator: _required,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            _isSubmitting
                                ? "Creating..."
                                : "Create Registration",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitRegistration,
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
