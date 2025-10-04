import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// ----------------------------------------------------------------------------
//                              Employee Registration Form
// ----------------------------------------------------------------------------

class EmployeeFormPage extends StatefulWidget {
  const EmployeeFormPage({super.key});

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  // 1. Face Verification State Variables
  bool _isProcessingImage = false;
  String _imageStatusMessage = '';
  String _imageErrorMessage = '';
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _empIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController(); // New field for salary

  // States
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  String? _department;
  String? _designation;
  String? _employmentType;
  DateTime? _joinDate;

  // Data for Dropdowns
  final List<String> _departments = [
    'Human Resources',
    'Marketing',
    'Development (IT)',
    'Finance',
    'Sales',
    'Administration',
  ];

  final Map<String, List<String>> _designationData = {
    'Human Resources': ['HR Manager', 'Recruiter', 'HR Coordinator'],
    'Marketing': [
      'Digital Marketing Head',
      'Content Creator',
      'SEO Specialist',
    ],
    'Development (IT)': [
      'Software Engineer',
      'DevOps Engineer',
      'Lead Developer',
    ],
    'Finance': ['Accounts Manager', 'Finance Analyst', 'Auditor'],
    'Sales': ['Sales Executive', 'Business Development Manager'],
    'Administration': ['Admin Manager', 'Office Assistant'],
  };

  final List<String> _employmentTypes = [
    'Full-Time',
    'Part-Time',
    'Contractual',
    'Internship',
  ];

  @override
  void dispose() {
    _empIdCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  //                              Helper Methods
  // --------------------------------------------------------------------------

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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final data = {
        "employeeId": _empIdCtrl.text,
        "name": _nameCtrl.text,
        "email": _emailCtrl.text,
        "mobile": _mobileCtrl.text,
        "department": _department,
        "designation": _designation,
        "employmentType": _employmentType,
        "salary": _salaryCtrl.text.isEmpty ? null : _salaryCtrl.text,
        "joinDate": _joinDate?.toIso8601String(),
      };
      Fluttertoast.showToast(
        msg: "Employee Registered Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: const Color(0xFF282C5C),
        fontSize: 16.0,
        backgroundColor: Colors.white,
      );
      print(data);
    }
  }

  // --------------------------------------------------------------------------
  //                              UI Components
  // --------------------------------------------------------------------------
  // 3. Face Detection Logic - MODIFIED
  Future<bool> _checkForFace(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    // Set minFaceSize for a more robust detection, reducing false positives on tiny objects
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        minFaceSize:
            0.2, // Require the face to take up at least 20% of the image
      ),
    );

    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      // 🔴 FIX 2: Check for EXACTLY ONE face 🔴
      return faces.length == 1;
    } catch (e) {
      debugPrint("Face detection error: $e");
      await faceDetector.close();
      return false;
    }
  }

  void _showImagePicker() {
    if (_isProcessingImage) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF282C5C),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndVerifyImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF282C5C)),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndVerifyImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndVerifyImage(ImageSource source) async {
    // 🔴 FIX: Add maxWidth and imageQuality parameters 🔴
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1000, // Max width/height of 1000 pixels
      imageQuality: 70, // Compress to 70% quality (0-100)
    );

    if (pickedFile != null) {
      // ... (rest of your existing logic)

      // 1. Set state to start processing
      setState(() {
        _isProcessingImage = true;
        _selectedImage = null; // Clear previous image
        _imageStatusMessage = 'Checking image for face... Please wait.';
        _imageErrorMessage = 'Checking image for face... Please wait.';
      });

      final imagePath = pickedFile.path;
      final inputImage = InputImage.fromFilePath(imagePath);

      // Use a local face detector instance to get the actual face count
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          minFaceSize: 0.2,
        ),
      );

      String status = '';

      try {
        final List<Face> faces = await faceDetector.processImage(inputImage);
        await faceDetector.close();

        // 2. Update state based on verification result
        if (faces.length == 1) {
          status = 'success';
        } else if (faces.isEmpty) {
          status = 'no_face';
        } else {
          status = 'multiple_faces';
        }
      } catch (e) {
        debugPrint("Face detection error: $e");
        await faceDetector.close();
        status = 'error';
      }

      // 3. Update state based on the determined status
      setState(() {
        _isProcessingImage = false;
        if (status == 'success') {
          _selectedImage = File(imagePath);
          _imageStatusMessage = '✅ Face detected successfully! Image is valid.';
          _imageErrorMessage = '';
        } else {
          _selectedImage = null;
          if (status == 'no_face') {
            _imageStatusMessage =
                '❌ Error: No face detected. Please ensure your face is clearly visible.';
            _imageErrorMessage =
                '❌ Error: No face detected. Please ensure your face is clearly visible.';
          } else if (status == 'multiple_faces') {
            _imageStatusMessage =
                '❌ Error: Multiple faces detected. Please upload an image with only one face.';
            _imageErrorMessage =
                '❌ Error: Multiple faces detected. Please upload an image with only one face.';
          } else {
            _imageStatusMessage =
                '❌ Error: Could not process image. Try again.';
            _imageErrorMessage = '❌ Error: Could not process image. Try again.';
          }
        }
      });
    } else {
      setState(() {
        _imageStatusMessage = 'Image selection cancelled.';
        _imageErrorMessage = 'Image selection cancelled.';
      });
    }
  }

  Widget _buildUploadField() {
    final bool isFaceVerified = _imageStatusMessage.startsWith('✅');
    final Color borderColor = isFaceVerified
        ? Colors.grey[300]!
        : (_imageStatusMessage.startsWith('❌')
              ? Colors.red
              : Colors.grey[300]!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Employee Photo",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 66, 66, 66),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
            ),
            child: _selectedImage == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Color(0xFF282C5C),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap to upload Image",
                          style: TextStyle(
                            color: Color(0xFF282C5C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          _imageErrorMessage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isFaceVerified
                ? Colors.green.shade700
                : (_imageStatusMessage.startsWith('❌')
                      ? Colors.red
                      : Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: _decoration(
            hintText: hintText,
            prefix: Icon(icon, color: const Color(0xFF282C5C)),
            suffix: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF282C5C),
                    ),
                    onPressed: onSuffixIconPressed,
                  )
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
    required List<String> items,
    required Function(String?) onChanged,
    String? hintText,
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
          initialValue: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: isRequired ? (v) => v == null ? "Required" : null : null,
          decoration: _decoration(
            prefix: Icon(icon, color: const Color(0xFF282C5C)),
          ).copyWith(hintText: hintText),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Joining Date",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 66, 66, 66),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _joinDate ?? now,
              firstDate: DateTime(now.year - 5), // Can join from past 5 years
              lastDate: DateTime(now.year + 1), // Can join within next year
            );
            if (picked != null) {
              setState(() => _joinDate = picked);
            }
          },
          child: InputDecorator(
            decoration:
                _decoration(
                  prefix: const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF282C5C),
                  ),
                ).copyWith(
                  hintText: _joinDate == null ? 'Select Joining Date' : null,
                ),
            child: Text(
              _joinDate == null
                  ? "Select Date"
                  : "${_joinDate!.day}/${_joinDate!.month}/${_joinDate!.year}",
              style: TextStyle(
                color: _joinDate == null ? Colors.grey : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  //                              Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282C5C),
        title: const Text(
          "Employee Registration Form",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
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
                        'Employee Details for Onboarding 🧑‍💼',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Text Fields
                    _buildTextField(
                      controller: _empIdCtrl,
                      label: "Employee ID",
                      icon: Icons.badge,
                      hintText: 'Enter Unique Employee ID',
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameCtrl,
                      label: "Full Name",
                      hintText: 'Enter Employee\'s Full Name',
                      icon: Icons.person,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailCtrl,
                      label: "Work Email",
                      hintText: 'Enter Work Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mobileCtrl,
                      label: "Mobile Number",
                      icon: Icons.phone,
                      hintText: 'Enter Contact Mobile Number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: _mobileValidator,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pwdCtrl,
                      hintText: 'Set Account Password',
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Password is required";
                        }
                        if (v.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        return null;
                      },
                      obscureText: _obscurePwd,
                      onSuffixIconPressed: () =>
                          setState(() => _obscurePwd = !_obscurePwd),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmCtrl,
                      label: "Confirm Password",
                      hintText: 'Confirm Account Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Please re-enter password";
                        }
                        if (v != _pwdCtrl.text) return "Passwords do not match";
                        return null;
                      },
                      obscureText: _obscureConfirm,
                      onSuffixIconPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 16),

                    // Dropdowns
                    _buildDropdown(
                      label: "Department",
                      icon: Icons.apartment,
                      value: _department,
                      items: _departments,
                      onChanged: (v) {
                        setState(() {
                          _department = v;
                          _designation = null; // Reset designation
                        });
                      },
                      hintText: 'Select Department',
                    ),
                    const SizedBox(height: 16),

                    // Designation (conditional)
                    if (_department != null &&
                        _designationData[_department] != null) ...[
                      _buildDropdown(
                        label: "Designation",
                        icon: Icons.work,
                        value: _designation,
                        items: _designationData[_department]!,
                        onChanged: (v) => setState(() => _designation = v),
                        isRequired: true,
                        hintText: 'Select Designation/Job Title',
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Employment Type
                    _buildDropdown(
                      label: "Employment Type",
                      icon: Icons.access_time,
                      value: _employmentType,
                      items: _employmentTypes,
                      onChanged: (v) => setState(() => _employmentType = v),
                      hintText: 'Select Type (e.g., Full-Time)',
                    ),
                    const SizedBox(height: 16),

                    // Joining Date
                    _buildDateField(),
                    const SizedBox(height: 16),

                    // Salary Field (Optional but useful)
                    // _buildTextField(
                    //   controller: _salaryCtrl,
                    //   label: "Monthly Salary (Optional)",
                    //   icon: Icons.attach_money,
                    //   hintText: 'Enter Monthly Salary (e.g., 50000)',
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.digitsOnly,
                    //   ],
                    //   validator: null, // Optional field
                    // ),
                    // const SizedBox(height: 24),

                    // Upload Image
                    _buildUploadField(),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Button will only be enabled if image is selected AND face is verified
                      onPressed:
                          (_selectedImage != null &&
                              _imageStatusMessage.startsWith('✅'))
                          ? _submit
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF282C5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
