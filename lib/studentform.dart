import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'; // Face Detection

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // 1. Face Verification State Variables
  bool _isProcessingImage = false;
  String _imageStatusMessage = '';
  String _imageErrorMessage = '';

  // controllers
  final _regCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // states
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  String? _branch;
  String? _course;
  String? _subCourse;
  String? _type;
  String? _duration;
  DateTime? _startDate;

  // 2. 🔴 FIX: Re-adding the missing _courseData map 🔴
  final Map<String, List<String>?> _courseData = {
    'Programming': ['Python Course', 'Java Course', 'C Course', 'C++ Course'],
    'Web Developement': [
      'Web Designing Course',
      'Web Development Course',
      'Mern Stack Course',
      'Mean Stack Course',
      'Php Full Stack Course',
    ],
    'Mobile Application Developement': [
      'Android',
      'Cross-Platform (Android/ios)',
    ],
    'Digital Marketing': [
      'Digital Marketing Course',
      'Social Media Marketing course',
      'Google Ads course',
      'Wordpress course',
      'Shopify course',
      'Search Engine Optimization course',
    ],
    'AI Courses': [
      'Power Bi course',
      'Tableau course',
      'Data Science Course',
      'Data Analytics Course',
      'Machine Learning Course',
      'Deep Learning Course',
      'Artificial Intelligence Course',
    ],
    'Cyber Courses': [
      'Cyber Security Course',
      'Cloud Computing Course',
      'Linux Course',
      'Ethical Hacking Course',
    ],
  };

  // 3. Face Detection Logic
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

  // Modified function to pick image and run verification
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
        _imageErrorMessage = 'Checking image for face... Please wait';
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
                _imageErrorMessage='❌ Error: Multiple faces detected. Please upload an image with only one face.';
          } else {
            _imageStatusMessage =
                '❌ Error: Could not process image. Try again.';
                _imageErrorMessage='❌ Error: Could not process image. Try again.';
          }
        }
      });
    } else {
      setState(() {
        _imageStatusMessage = 'Image selection cancelled.';
        _imageErrorMessage='Image selection camcelled';
      });
    }
  }

  // Modified _buildUploadField to show status and loading indicator
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
          "Upload Student Image",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 66, 66, 66),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isProcessingImage
              ? null
              : _showImagePicker, // Disable tap during processing
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
            ),
            child: _selectedImage == null
                ? Center(
                    child: _isProcessingImage
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF282C5C),
                            ),
                          )
                        : const Column(
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
        const SizedBox(height: 8),
        // Status message display
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

  // Dispose method
  @override
  void dispose() {
    _regCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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

  void _submit() {
    FocusScope.of(context).unfocus();
    // Check if image is selected and verified
    if (_selectedImage == null || !_imageStatusMessage.startsWith('✅')) {
      Fluttertoast.showToast(
        msg: "Please upload a verified image with a clearly visible face.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final data = {
        "reg": _regCtrl.text,
        "name": _nameCtrl.text,
        "email": _emailCtrl.text,
        "mobile": _mobileCtrl.text,
        "branch": _branch,
        "course": _course,
        "subCourse": _subCourse,
        "type": _type,
        "duration": _duration,
        "startDate": _startDate?.toIso8601String(),
        // Include the image file path/reference for backend upload
        "image_path": _selectedImage!.path,
      };
      Fluttertoast.showToast(
        msg: "Data Added Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: const Color(0xFF282C5C),
        fontSize: 16.0,
        backgroundColor: Colors.white,
      );
      print(data);
    }
  }

  List<String> _getDurationOptions() {
    if (_type == "Industrial Training") {
      return ['45 Days', '2 Months', '6 Months'];
    } else if (_type == "Vocational Course") {
      return List.generate(12, (i) => "${i + 1} Month${i > 0 ? 's' : ''}");
    }
    return [];
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
          "Start Date",
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
              initialDate: _startDate ?? now,
              firstDate: now,
              lastDate: DateTime(now.year + 1),
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
              setState(() => _startDate = picked);
            }
          },
          child: InputDecorator(
            decoration: _decoration(
              prefix: const Icon(
                Icons.calendar_month,
                color: Color(0xFF282C5C),
              ),
            ).copyWith(hintText: _startDate == null ? 'Select a date' : null),
            child: Text(
              _startDate == null
                  ? "Select Date"
                  : "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}",
              style: TextStyle(
                color: _startDate == null ? Colors.grey : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282C5C),
        title: const Text(
          "Student Registration Form",
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
                        'Fill out the form to register',
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
                      controller: _regCtrl,
                      label: "Registration Number",
                      icon: Icons.badge,
                      hintText: 'Enter Registration Number',
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameCtrl,
                      label: "Name",
                      hintText: 'Enter Your Name',
                      icon: Icons.person,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailCtrl,
                      label: "Email",
                      hintText: 'Enter Your Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mobileCtrl,
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
                      controller: _pwdCtrl,
                      hintText: 'Enter Password',
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
                      hintText: 'Confirm Password',
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
                      label: "Branch",
                      icon: Icons.business,
                      value: _branch,
                      items: const [
                        'Jalandhar-I',
                        'Jalandhar-II',
                        'Phagwara',
                        'Hoshiarpur',
                        'Ludhiana',
                        'Chandigarh',
                      ],
                      onChanged: (v) => setState(() => _branch = v),
                      hintText: 'Select Branch',
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: "Course",
                      icon: Icons.school,
                      value: _course,
                      // Accessing the now-present _courseData
                      items: _courseData.keys.toList(),
                      onChanged: (v) {
                        setState(() {
                          _course = v;
                          _subCourse = null; // Reset sub-course
                          _duration = null; // Reset duration
                        });
                      },
                      hintText: 'Select Course',
                    ),

                    // Sub-Course (conditional)
                    if (_course != null && _courseData[_course] != null) ...[
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: "Sub-Category",
                        icon: Icons.category,
                        value: _subCourse,
                        // Accessing the now-present _courseData
                        items: _courseData[_course]!,
                        onChanged: (v) => setState(() => _subCourse = v),
                        isRequired: true,
                        hintText: 'Select Sub-Category',
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Type of course
                    _buildDropdown(
                      label: "Type of Course",
                      icon: Icons.work,
                      value: _type,
                      items: const ["Industrial Training", "Vocational Course"],
                      onChanged: (v) {
                        setState(() {
                          _type = v;
                          _duration = null;
                        });
                      },
                      hintText: 'Select Type',
                    ),

                    // Duration (conditional on Type)
                    if (_type != null) ...[
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: "Duration",
                        icon: Icons.timelapse,
                        value: _duration,
                        items: _getDurationOptions(),
                        onChanged: (v) => setState(() => _duration = v),
                        hintText: 'Select Duration',
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Start Date
                    _buildDateField(),
                    const SizedBox(height: 24),

                    // Upload Image (with Face Verification)
                    _buildUploadField(),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
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
                                    !_isProcessingImage &&
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
                        ),
                      ],
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
