// lib/services/api_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:techcadd/models/course_models.dart';
import 'package:techcadd/models/dropdown_models.dart';
import 'package:techcadd/models/staff_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.1.86:8000';
  static String? accessToken;
   static String? studentAccessToken;


  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = accessToken ?? prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Handle API errors
  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Something went wrong');
    }
  }

  static Future<Map<String, dynamic>> adminLogin(String username, String password) async {
  try {
    final url = Uri.parse('$baseUrl/api/admin/login/');
    print('🔐 Login URL: $url');
    
    final response = await http.post(
      url,
      body: json.encode({
        'username': username,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    print('📡 Login Response Status: ${response.statusCode}');
    print('📦 Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Debug: Print what we received
      print('✅ Login successful');
      print('   User: ${data['user']}');
      print('   Access Token: ${data['tokens']['access'] != null ? "Exists" : "Missing"}');
      print('   Refresh Token: ${data['tokens']['refresh'] != null ? "Exists" : "Missing"}');
      
      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['tokens']['access']);
      await prefs.setString('refresh_token', data['tokens']['refresh']);
      await prefs.setString('user_data', json.encode(data['user']));
      
      // Also set the static variable
      accessToken = data['tokens']['access'];
      
      // Verify tokens were saved
      final savedAccessToken = prefs.getString('access_token');
      final savedRefreshToken = prefs.getString('refresh_token');
      
      print('💾 Tokens saved verification:');
      print('   Access Token saved: ${savedAccessToken != null ? "Yes" : "No"}');
      print('   Refresh Token saved: ${savedRefreshToken != null ? "Yes" : "No"}');
      print('   Static accessToken: ${accessToken != null ? "Set" : "Not set"}');
      
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Login failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Login error: $e');
    rethrow;
  }
}
static Future<void> debugStoredTokens() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');
    final userData = prefs.getString('user_data');
    
    print('🔍 DEBUG - Stored Tokens:');
    print('   Access Token: ${accessToken != null ? "Exists (${accessToken.length} chars)" : "NULL"}');
    print('   Refresh Token: ${refreshToken != null ? "Exists (${refreshToken.length} chars)" : "NULL"}');
    print('   User Data: ${userData != null ? "Exists" : "NULL"}');
    print('   Static accessToken: ${accessToken != null ? "Set" : "NULL"}');
    
    if (accessToken != null) {
      print('   First 20 chars of access token: ${accessToken.substring(0, min(20, accessToken.length))}...');
    }
  } catch (e) {
    print('❌ Debug tokens error: $e');
  }
}
  // Verify admin token
  static Future<Map<String, dynamic>> verifyAdminToken() async {
    final url = Uri.parse('$baseUrl/verify-token/');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response);
      return {};
    }
  }

  // Get admin profile
 static Future<Map<String, dynamic>> getAdminProfile() async {
  try {
    final url = Uri.parse('$baseUrl/api/admin/profile/');
    print('🔍 Profile URL: $url');
    
    final headers = await _getHeaders();
    print('🔍 Profile Headers: ${headers.containsKey('Authorization') ? "Has Auth" : "No Auth"}');
    
    final response = await http.get(
      url,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('📥 Profile Response Status: ${response.statusCode}');
    print('📥 Profile Response Headers: ${response.headers}');
    print('📥 Profile Response Body (first 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');

    if (response.statusCode == 200) {
      // Check if response is actually JSON
      if (response.body.trim().startsWith('{') || response.body.trim().startsWith('[')) {
        return json.decode(response.body);
      } else {
        throw Exception('Server returned non-JSON response');
      }
    } else {
      throw Exception('Failed to get profile: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Profile error: $e');
    rethrow;
  }
}
  // Logout
  static Future<void> adminLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken != null) {
      final url = Uri.parse('$baseUrl/logout/');
      await http.post(
        url,
        body: json.encode({'refresh_token': refreshToken}),
        headers: await _getHeaders(),
      );
    }

    // Clear local storage
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    accessToken = null;
  }

  // Dashboard Statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    // This endpoint needs to be created in your Django backend
    final url = Uri.parse('$baseUrl/dashboard/stats/');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Return mock data for now - replace with actual API call
      return {
        'daily_registration': 2,
        'daily_collection': 8170,
        'daily_attendance': 92,
        'daily_expense': 0,
        'enquiry_stats': {
          'random_calls': 5,
          'visited': 6,
          'register': 10,
          'daily_enquiries': 2,
          'daily_registration_count': 2,
          'daily_expense_count': 0,
        },
        'course_enquiries': {
          'computer_it': 5,
          'cse_it': 0,
          'graphic_designing': 2,
          'digital_marketing': 0,
        },
      };
    }
  }

  static Future<List<dynamic>> getCertificates() async {
    // This endpoint needs to be created in your Django backend
    final url = Uri.parse('$baseUrl/certificates/');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['certificates'] ?? [];
    } else {
      // Mock data for now
      return [
        {
          'id': 1,
          'reg_no': 'TCD/4001/3805',
          'name': 'Himanshi',
          'course': 'Computer Typing',
          'email': 'himanshi@example.com',
        },
        {
          'id': 2,
          'reg_no': 'TCD/4001/2857',
          'name': 'Parminder Singh',
          'course': 'Graphic Designing',
          'email': 'parminder@example.com',
        },
      ];
    }
  }

  // Add these methods to your existing ApiService class
  static Future<List<Course>> getStudentCourses() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/courses/');
      final response = await http
          .get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List<dynamic>)
            .map((course) => Course.fromJson(course))
            .toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Courses error: $e');

      // Return mock data for testing
      return _getMockCourses();
    }
  }

  static Future<Course> getCourseDetail(int courseId) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/courses/$courseId/');
      final response = await http
          .get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Course.fromJson(data);
      } else {
        throw Exception('Failed to load course detail: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Course detail error: $e');

      // Return mock data for testing
      return _getMockCourseDetail(courseId);
    }
  }

  // Mock data for testing
  static List<Course> _getMockCourses() {
    return [
      Course(
        id: 8,
        name: "Web Development",
        description:
            "Complete web development course covering HTML, CSS, and JavaScript",
        duration: "3 months",
        fees: 15000.0,
        modules: [],
        totalModules: 3,
        totalLessons: 8,
        completedLessons: 0,
        overallProgress: 0,
      ),
    ];
  }

  static Course _getMockCourseDetail(int courseId) {
    // This matches your Django sample data
    final modules = [
      CourseModule(
        id: 1,
        title: "HTML Fundamentals",
        description: "Learn the basics of HTML and structure web pages",
        order: 1,
        lessons: [
          Lesson(
            id: 1,
            title: "Introduction to HTML",
            description: "What is HTML and why we use it",
            lessonType: "video",
            order: 1,
            videoUrl: "https://www.youtube.com/watch?v=example1",
            durationMinutes: 30,
            isCompleted: false,
            progressPercentage: 0,
          ),
          Lesson(
            id: 2,
            title: "HTML Tags and Elements",
            description: "Understanding HTML tags, elements and attributes",
            lessonType: "video",
            order: 2,
            videoUrl: "https://www.youtube.com/watch?v=example2",
            durationMinutes: 45,
            isCompleted: false,
            progressPercentage: 0,
          ),
          Lesson(
            id: 3,
            title: "HTML Document Structure",
            description: "Learn about HTML document structure",
            lessonType: "text",
            order: 3,
            textContent:
                "HTML documents have a specific structure with head and body sections...",
            durationMinutes: 20,
            isCompleted: false,
            progressPercentage: 0,
          ),
        ],
        completedLessons: 0,
        totalLessons: 3,
        progressPercentage: 0,
      ),
      CourseModule(
        id: 2,
        title: "CSS Fundamentals",
        description: "Style your web pages with CSS",
        order: 2,
        lessons: [
          Lesson(
            id: 4,
            title: "Introduction to CSS",
            description: "What is CSS and how to use it",
            lessonType: "video",
            order: 1,
            videoUrl: "https://www.youtube.com/watch?v=example3",
            durationMinutes: 35,
            isCompleted: false,
            progressPercentage: 0,
          ),
          Lesson(
            id: 5,
            title: "CSS Selectors",
            description: "Learn different types of CSS selectors",
            lessonType: "video",
            order: 2,
            videoUrl: "https://www.youtube.com/watch?v=example4",
            durationMinutes: 40,
            isCompleted: false,
            progressPercentage: 0,
          ),
        ],
        completedLessons: 0,
        totalLessons: 2,
        progressPercentage: 0,
      ),
      CourseModule(
        id: 3,
        title: "JavaScript Basics",
        description: "Add interactivity to your web pages",
        order: 3,
        lessons: [
          Lesson(
            id: 6,
            title: "Introduction to JavaScript",
            description: "Getting started with JavaScript",
            lessonType: "video",
            order: 1,
            videoUrl: "https://www.youtube.com/watch?v=example5",
            durationMinutes: 50,
            isCompleted: false,
            progressPercentage: 0,
          ),
        ],
        completedLessons: 0,
        totalLessons: 1,
        progressPercentage: 0,
      ),
    ];

    return Course(
      id: courseId,
      name: "Web Development",
      description:
          "Complete web development course covering HTML, CSS, and JavaScript",
      duration: "3 months",
      fees: 15000.0,
      modules: modules,
      totalModules: 3,
      totalLessons: 6,
      completedLessons: 0,
      overallProgress: 0,
    );
  }




static Future<StaffListResponse> getStaffList() async {
  try {
    final url = Uri.parse('$baseUrl/api/admin/staff/list/');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StaffListResponse.fromJson(data);
    } else {
      throw Exception('Failed to load staff list: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Staff list error: $e');
    
    // Return mock data for testing
    return _getMockStaffList();
  }
}

static Future<StaffProfile> getStaffDetail(int staffId) async {
  try {
    final url = Uri.parse('$baseUrl/api/admin/staff/$staffId/');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StaffProfile.fromJson(data);
    } else {
      throw Exception('Failed to load staff detail: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Staff detail error: $e');
    
    // Return mock data for testing
    return _getMockStaffDetail(staffId);
  }
}


static Future<Map<String, dynamic>> updateStaffStatus(
  int staffId, 
  bool isActive, 
  {
    String? role, 
    String? department, 
    String? phone, 
    String? address
  }
) async {
  try {
    final url = Uri.parse('$baseUrl/api/admin/staff/$staffId/update/');
    
    
    final Map<String, dynamic> updateData = {
      'is_active': isActive,
    };
    
    
    if (role != null) updateData['role'] = role;
    if (department != null) updateData['department'] = department;
    if (phone != null) updateData['phone'] = phone;
    if (address != null) updateData['address'] = address;
    
    print('📤 Update data: $updateData'); 
    
    final response = await http.put(
      url,
      body: json.encode(updateData),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    print('📥 Response: ${response.statusCode} - ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update staff');
    }
  } catch (e) {
    print('❌ Update staff error: $e');
    rethrow;
  }
}
static Future<Map<String, dynamic>> deleteStaffAccount(int staffId) async {
  try {
    final url = Uri.parse('$baseUrl/api/admin/staff/$staffId/delete/');
    final response = await http.delete(
      url,
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete staff: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Delete staff error: $e');
    rethrow;
  }
}
// Add to ApiService class
static Future<Map<String, dynamic>> updateEnquiry(
  int enquiryId, 
  Map<String, dynamic> updateData
) async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/students/$enquiryId/update/');
    
    print('✏️ Updating enquiry $enquiryId with data: $updateData');
    
    final response = await _apiCallWithTokenRefresh(() async {
      return await http.put(
        url,
        body: json.encode(updateData),
        headers: await _getStaffHeaders(),
      ).timeout(const Duration(seconds: 10));
    });

    print('📡 Update Enquiry Response Status: ${response.statusCode}');
    print('📦 Update Enquiry Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Enquiry updated successfully');
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update enquiry: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Update enquiry error: $e');
    rethrow;
  }
}

static Future<Map<String, dynamic>> quickUpdateEnquiryStatus(
  int enquiryId, 
  String newStatus
) async {
  return await updateEnquiry(enquiryId, {
    'enquiry_status': newStatus,
  });
}
// Mock data for testing
static StaffListResponse _getMockStaffList() {
  return StaffListResponse(
    staffCount: 3,
    staffList: [
      StaffProfile(
        id: 1,
        username: 'john_doe',
        email: 'john@techcadd.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'Manager',
        department: 'Administration',
        phone: '9876543210',
        address: 'Jalandhar',
        isActive: true,
        dateJoined: DateTime(2024, 1, 1),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      StaffProfile(
        id: 2,
        username: 'jane_smith',
        email: 'jane@techcadd.com',
        firstName: 'Jane',
        lastName: 'Smith',
        role: 'Trainer',
        department: 'Training',
        phone: '9876543211',
        address: 'Phagwara',
        isActive: true,
        dateJoined: DateTime(2024, 1, 15),
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      ),
      StaffProfile(
        id: 3,
        username: 'mike_wilson',
        email: 'mike@techcadd.com',
        firstName: 'Mike',
        lastName: 'Wilson',
        role: 'Counselor',
        department: 'Admissions',
        phone: '9876543212',
        address: 'Ludhiana',
        isActive: false,
        dateJoined: DateTime(2024, 2, 1),
        lastLogin: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ],
  );
}

static StaffProfile _getMockStaffDetail(int staffId) {
  return StaffProfile(
    id: staffId,
    username: 'john_doe',
    email: 'john@techcadd.com',
    firstName: 'John',
    lastName: 'Doe',
    role: 'Manager',
    department: 'Administration',
    phone: '9876543210',
    address: 'Jalandhar, Punjab',
    isActive: true,
    dateJoined: DateTime(2024, 1, 1),
    lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
  );
}
// Add token refresh method
static Future<void> refreshAccessToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final url = Uri.parse('$baseUrl/api/admin/token/refresh/');
    final response = await http.post(
      url,
      body: json.encode({'refresh': refreshToken}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access'];
      
      await prefs.setString('access_token', newAccessToken);
      accessToken = newAccessToken;
      
      print('✅ Access token refreshed successfully');
    } else {
      throw Exception('Failed to refresh token: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Token refresh error: $e');
    rethrow;
  }
}

static Future<Map<String, dynamic>> createStaffAccount(CreateStaffRequest staffData) async {
  try {
    // First, debug what tokens we have
    await debugStoredTokens();
    
    final url = Uri.parse('$baseUrl/api/admin/staff/create/');
    
    print('📤 Creating staff account...');
    print('📤 URL: $url');
    print('📤 Staff Data: ${staffData.toJson()}');
    
    // Get headers and debug them
    final headers = await _getHeaders();
    print('📤 Headers being sent:');
    headers.forEach((key, value) {
      if (key == 'Authorization') {
        print('   $key: Bearer [TOKEN] (length: ${value.length})');
      } else {
        print('   $key: $value');
      }
    });
    
    final response = await http.post(
      url,
      body: json.encode(staffData.toJson()),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print('✅ Staff account created successfully');
      return data;
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['error'] ?? errorData['detail'] ?? 'Failed to create staff account';
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('❌ Create staff error: $e');
    rethrow;
  }
}
static Future<void> testCompleteFlow() async {
  try {
    print('🚀 Testing complete login -> create staff flow...');
    
    // Step 1: Login
    print('1. Logging in...');
    final loginResponse = await adminLogin('your_admin_username', 'your_admin_password');
    print('   Login result: ${loginResponse['message']}');
    
    // Step 2: Check tokens
    print('2. Checking stored tokens...');
    await debugStoredTokens();
    
    // Step 3: Verify token works
    print('3. Verifying token...');
    final profileResponse = await getAdminProfile();
    print('   Profile verification: ${profileResponse.isNotEmpty ? "Success" : "Failed"}');
    
    // Step 4: Create staff
    print('4. Creating staff...');
    final staffData = CreateStaffRequest(
      username: 'teststaff_${DateTime.now().millisecondsSinceEpoch}',
      email: 'test${DateTime.now().millisecondsSinceEpoch}@techcadd.com',
      password: 'password123',
      firstName: 'Test',
      lastName: 'Staff',
      role: 'Trainer',
      department: 'Training',
      phone: '9876543210',
      address: 'Test Address',
    );
    
    final staffResponse = await createStaffAccount(staffData);
    print('   Staff creation: ${staffResponse['message']}');
    
    print('✅ Complete flow test finished');
  } catch (e) {
    print('❌ Flow test failed: $e');
  }
}


static Future<Map<String, dynamic>> staffLogin(String username, String password) async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/login/');
    print('🔐 Staff Login URL: $url');
    
    final response = await http.post(
      url,
      body: json.encode({
        'username': username,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    print('📡 Staff Login Response Status: ${response.statusCode}');
    print('📦 Staff Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Check for success message in your response structure
      if (data['message'] == 'Staff login successful') {
        // Store staff data and tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staff_data', json.encode(data['staff_profile']));
        await prefs.setString('staff_access_token', data['tokens']['access']);
        await prefs.setString('staff_refresh_token', data['tokens']['refresh']);
        
        print('✅ Staff login successful');
        return {
          'success': true,
          'staff': data['staff_profile'],
          'tokens': data['tokens']
        };
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Staff login failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Staff login error: $e');
    rethrow;
  }
}


static Future<StaffProfile> getStaffProfile() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final staffData = prefs.getString('staff_data');
    
    if (staffData == null) {
      throw Exception('No staff data found. Please login again.');
    }
    
    final data = json.decode(staffData);
    return StaffProfile.fromJson(data);
  } catch (e) {
    print('❌ Staff profile error: $e');
    rethrow;
  }
}

static Future<Map<String, String>> _getStaffHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('staff_access_token');

  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}



static Future<bool> isStaffLoggedIn() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final staffData = prefs.getString('staff_data');
    final accessToken = prefs.getString('staff_access_token');
    
    if (staffData != null && accessToken != null) {
      final data = json.decode(staffData);
      final staff = StaffProfile.fromJson(data);
      return staff.isActive;
    }
    return false;
  } catch (e) {
    return false;
  }
}


// Staff logout with API call (for manual logout)
static Future<void> staffLogout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('staff_refresh_token');
    
    // Call logout API if we have a token
    if (refreshToken != null) {
      final url = Uri.parse('$baseUrl/api/staff/logout/');
      await http.post(
        url,
        body: json.encode({'refresh_token': refreshToken}),
        headers: await _getStaffHeaders(),
      ).timeout(const Duration(seconds: 5));
    }
  } catch (e) {
    print('⚠️ Staff logout API call failed: $e');
    // Continue with local cleanup even if API call fails
  } finally {
    // Always clear local storage
    await _clearStaffData();
  }
}

// Clear staff data without API call (for app close/destroy)
static Future<void> _clearStaffData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('staff_data');
    await prefs.remove('staff_access_token');
    await prefs.remove('staff_refresh_token');
    print('✅ Staff data cleared from local storage');
  } catch (e) {
    print('❌ Error clearing staff data: $e');
  }
}

// Auto logout when app is destroyed (call this from main.dart)
static Future<void> staffLogoutOnAppClose() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final shouldLogoutOnClose = prefs.getBool('staff_auto_logout') ?? true;
    
    if (shouldLogoutOnClose) {
      await _clearStaffData();
      print('✅ Staff auto-logout completed on app close');
    }
  } catch (e) {
    print('❌ Staff auto-logout error: $e');
  }
}

// Set auto logout preference
static Future<void> setStaffAutoLogout(bool enable) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('staff_auto_logout', enable);
}
// Add to lib/techcadd/api_service.dart

// Get dropdown choices for enquiries
static Future<DropdownChoices> getEnquiryDropdownChoices() async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/students/options/');
    final response = await http.get(
      url,
      headers: await _getStaffHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DropdownChoices.fromJson(data);
    } else {
      throw Exception('Failed to load dropdown choices: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Dropdown choices error: $e');
    
    // Return mock data for testing
    return _getMockDropdownChoices();
  }
}

// Mock data for dropdown choices
static DropdownChoices _getMockDropdownChoices() {
  return DropdownChoices(
    centreChoices: [
      DropdownChoice(value: 'jalandhar1', label: 'Jalandhar 1'),
      DropdownChoice(value: 'jalandhar2', label: 'Jalandhar 2'),
      DropdownChoice(value: 'phagwara', label: 'Phagwara'),
    ],
    tradeChoices: [
      DropdownChoice(value: 'computer', label: 'Computer'),
      DropdownChoice(value: 'graphic_designing', label: 'Graphic Designing'),
      DropdownChoice(value: 'digital_marketing', label: 'Digital Marketing'),
    ],
    enquirySourceChoices: [
      DropdownChoice(value: 'social_media', label: 'Social Media'),
      DropdownChoice(value: 'direct_visit', label: 'Direct Visit'),
      DropdownChoice(value: 'reference', label: 'Reference'),
    ],
    enquiryStatusChoices: [
      DropdownChoice(value: 'in_process', label: 'In Process'),
      DropdownChoice(value: 'visited', label: 'Visited'),
      DropdownChoice(value: 'registration_done', label: 'Registration Done'),
    ],
    staffOptions: [
      StaffOption(id: 1, name: 'Counselor 1'),
      StaffOption(id: 2, name: 'Counselor 2'),
    ],
  );
}
// Add token refresh method in ApiService
static Future<bool> refreshStaffToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('staff_refresh_token');
    
    if (refreshToken == null) {
      print('❌ No refresh token available');
      return false;
    }
    
    final url = Uri.parse('$baseUrl/api/staff/token/refresh/');
    print('🔄 Refreshing staff token...');
    
    final response = await http.post(
      url,
      body: json.encode({'refresh': refreshToken}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('📡 Token Refresh Response Status: ${response.statusCode}');
    print('📦 Token Refresh Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access'];
      
      await prefs.setString('staff_access_token', newAccessToken);
      print('✅ Staff access token refreshed successfully');
      return true;
    } else {
      print('❌ Token refresh failed: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ Token refresh error: $e');
    return false;
  }
}

static Future<Map<String, dynamic>> createEnquiry(Map<String, dynamic> enquiryData) async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/students/create/');
    
    print('📝 Creating enquiry with data: $enquiryData');
    
    // First attempt
    var response = await http.post(
      url,
      body: json.encode(enquiryData),
      headers: await _getStaffHeaders(),
    ).timeout(const Duration(seconds: 10));

    print('📡 Create Enquiry Response Status: ${response.statusCode}');
    print('📦 Create Enquiry Response Body: ${response.body}');

    // If token is invalid, try refreshing token and retry
    if (response.statusCode == 401) {
      print('🔄 Token expired, attempting refresh...');
      final tokenRefreshed = await refreshStaffToken();
      
      if (tokenRefreshed) {
        // Retry with new token
        response = await http.post(
          url,
          body: json.encode(enquiryData),
          headers: await _getStaffHeaders(),
        ).timeout(const Duration(seconds: 10));

        print('🔄 Retry Response Status: ${response.statusCode}');
        print('🔄 Retry Response Body: ${response.body}');
      } else {
        // Token refresh failed, need to logout
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Enquiry created successfully');
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? errorData['detail'] ?? 'Failed to create enquiry: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Create enquiry error: $e');
    rethrow;
  }
}
// Add to lib/techcadd/api_service.dart
static Future<http.Response> _apiCallWithTokenRefresh(Future<http.Response> Function() apiCall) async {
  // First attempt
  var response = await apiCall();
  
  // If token is invalid, refresh and retry
  if (response.statusCode == 401) {
    print('🔄 Token expired, attempting refresh...');
    final tokenRefreshed = await refreshStaffToken();
    
    if (tokenRefreshed) {
      // Retry with new token
      response = await apiCall();
    } else {
      // Token refresh failed
      throw Exception('Session expired. Please login again.');
    }
  }
  
  return response;
}
// In ApiService class - Update getStaffDashboardStats method

static Future<Map<String, dynamic>> getStaffDashboardStats() async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/dashboard/');
    final headers = await _getStaffHeaders();
    
    final response = await http.get(
      url,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('📡 Dashboard Response Status: ${response.statusCode}');
    print('📡 Dashboard Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Extract data from the quick_stats object
      final quickStats = data['quick_stats'] ?? {};
      
      print('✅ Dashboard stats loaded: $quickStats');
      return {
        'total_enquiries': quickStats['total_enquiries'] ?? 0,
        'new_registrations': quickStats['new_registrations'] ?? 0,
        'pending_fees': quickStats['pending_fees'] ?? 0,
        'certificates_generated': quickStats['certificates_generated'] ?? 0,
      };
    } else {
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Dashboard stats error: $e');
    
    
    return {
      'total_enquiries': 0,
      'new_registrations': 0,
      'pending_fees': 0,
      'certificates_generated': 0,
    };
  }
}

// Add to ApiService class

// Get students with pending fees
static Future<List<dynamic>> getStudentsWithPendingFees() async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/registrations/list/');
    final response = await _apiCallWithTokenRefresh(() async {
      return await http.get(
        url,
        headers: await _getStaffHeaders(),
      ).timeout(const Duration(seconds: 10));
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final registrations = data['registrations'] as List<dynamic>? ?? [];
      
      // Filter students with pending fees
      final pendingFeesStudents = registrations.where((registration) {
        final registrationMap = registration as Map<String, dynamic>;
        final feeBalance = double.tryParse(registrationMap['fee_balance']?.toString() ?? '0') ?? 0;
        return feeBalance > 0;
      }).toList();
      
      print('✅ Pending fees students: ${pendingFeesStudents.length}');
      return pendingFeesStudents;
    } else {
      throw Exception('Failed to load pending fees students: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Get pending fees students error: $e');
    return [];
  }
}

// Add fee payment
static Future<Map<String, dynamic>> addFeePayment({
  required String registrationNumber,
  required double amount,
  required String paymentMode,
  String? transactionId,
  String? remark,
}) async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/registrations/add-payment/?registration_number=$registrationNumber');
    
    final paymentData = {
      'amount': amount,
      'payment_mode': paymentMode,
      'transaction_id': transactionId ?? '',
      'remark': remark ?? '',
    };
    
    print('💰 Adding fee payment: $paymentData');
    
    var response = await http.post(
      url,
      body: json.encode(paymentData),
      headers: await _getStaffHeaders(),
    ).timeout(const Duration(seconds: 10));

    print('📡 Add Payment Response Status: ${response.statusCode}');
    print('📦 Add Payment Response Body: ${response.body}');

    // If token is invalid, try refreshing token and retry
    if (response.statusCode == 401) {
      print('🔄 Token expired, attempting refresh...');
      final tokenRefreshed = await refreshStaffToken();
      
      if (tokenRefreshed) {
        response = await http.post(
          url,
          body: json.encode(paymentData),
          headers: await _getStaffHeaders(),
        ).timeout(const Duration(seconds: 10));
      } else {
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Fee payment added successfully');
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? errorData['detail'] ?? 'Failed to add payment: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Add fee payment error: $e');
    rethrow;
  }
}
static Future<Map<String, dynamic>> getEnquiryStats() async {
  try {
    print('📊 Fetching enquiry stats...');
    final headers = await _getStaffHeaders();
    
    final url = Uri.parse('$baseUrl/api/staff/students/stats/');
    print('📊 URL: $url');
    
    final response = await http.get(
      url,
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('📡 Stats Response Status: ${response.statusCode}');
    print('📡 Stats Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print('✅ Enquiry stats loaded successfully');
      
      // Extract status counts from the new response structure
      final statusCounts = data['status_counts'] ?? {};
      final totalStudents = data['total_students'] ?? 0;
      
      // Create a map with all status counts
      final stats = {
        'all': totalStudents,
        'registration_done': statusCounts['registration_done'] ?? 0,
        'visited': statusCounts['visited'] ?? 0,
        'in_process': statusCounts['in_process'] ?? 0,
        'negative': statusCounts['negative'] ?? 0,
        'positive': statusCounts['positive'] ?? 0,
        'follow_up_required': statusCounts['follow_up_required'] ?? 0,
        'admission_done': statusCounts['admission_done'] ?? 0,
        'course_completed': statusCounts['course_completed'] ?? 0,
        'dropped': statusCounts['dropped'] ?? 0,
      };
      
      print('📊 Parsed stats: $stats');
      return stats;
    } else {
      print('❌ Stats API error: ${response.statusCode}');
      throw Exception('Failed to load enquiry stats: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Enquiry stats error: $e');
    
    // Return empty stats with all statuses
    return {
      'all': 0,
      'registration_done': 0,
      'visited': 0,
      'in_process': 0,
      'negative': 0,
      'positive': 0,
      'follow_up_required': 0,
      'admission_done': 0,
      'course_completed': 0,
      'dropped': 0,
    };
  }
}static Future<List<dynamic>> getEnquiries({String? status}) async {
  try {
    print('📋 Fetching enquiries...');
    final headers = await _getStaffHeaders();
    
    final url = Uri.parse('$baseUrl/api/staff/students/list');
    print('📋 URL: $url');
    print('📋 Headers: ${headers.containsKey('Authorization') ? "Has Auth" : "No Auth"}');
    
    final response = await _apiCallWithTokenRefresh(() async {
      return await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));
    });

    print('📡 Enquiries Response Status: ${response.statusCode}');
    print('📡 Enquiries Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print('📋 Response keys: ${data.keys}');
      
      final enquiries = data['students'] as List<dynamic>? ?? [];
      print('✅ Enquiries loaded successfully: ${enquiries.length} items');
      
      // Debug first enquiry if available
      if (enquiries.isNotEmpty) {
        print('🔍 First enquiry: ${enquiries[0]}');
      }
      
      return enquiries;
    } else {
      print('❌ Enquiries API error: ${response.statusCode}');
      throw Exception('Failed to load enquiries: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Get enquiries error: $e');
    return [];
  }
}


// lib/services/api_service.dart - Add these methods

// Get registration dropdown choices
static Future<Map<String, dynamic>> getRegistrationOptions() async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/registrations/options/');
    final response = await http.get(
      url,
      headers: await _getStaffHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load registration options: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Registration options error: $e');
    return {};
  }
}

// Get courses by course type
static Future<List<dynamic>> getCoursesByType(int courseTypeId) async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/registrations/courses/$courseTypeId/');
    final response = await http.get(
      url,
      headers: await _getStaffHeaders(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load courses: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Courses by type error: $e');
    return [];
  }
}

// Create student registration
static Future<Map<String, dynamic>> createStudentRegistration(Map<String, dynamic> registrationData) async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/registrations/create/');
    
    print('📝 Creating student registration with data: $registrationData');
    
    var response = await http.post(
      url,
      body: json.encode(registrationData),
      headers: await _getStaffHeaders(),
    ).timeout(const Duration(seconds: 10));

    print('📡 Create Registration Response Status: ${response.statusCode}');
    print('📦 Create Registration Response Body: ${response.body}');

    // If token is invalid, try refreshing token and retry
    if (response.statusCode == 401) {
      print('🔄 Token expired, attempting refresh...');
      final tokenRefreshed = await refreshStaffToken();
      
      if (tokenRefreshed) {
        response = await http.post(
          url,
          body: json.encode(registrationData),
          headers: await _getStaffHeaders(),
        ).timeout(const Duration(seconds: 10));
      } else {
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Student registration created successfully');
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? errorData['detail'] ?? 'Failed to create registration: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Create registration error: $e');
    rethrow;
  }
}

// Get all student registrations
static Future<List<dynamic>> getStudentRegistrations() async {
  try {
    final url = Uri.parse('$baseUrl/api/staff/registrations/list/');
    final response = await _apiCallWithTokenRefresh(() async {
      return await http.get(
        url,
        headers: await _getStaffHeaders(),
      ).timeout(const Duration(seconds: 10));
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final registrations = data['registrations'] as List<dynamic>? ?? [];
      print('✅ Registrations loaded successfully: ${registrations.length} items');
      return registrations;
    } else {
      throw Exception('Failed to load registrations: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Get registrations error: $e');
    return [];
  }
}
  static Future<Map<String, String>> _getStudentHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = studentAccessToken ?? prefs.getString('student_access_token');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Student Login
  static Future<Map<String, dynamic>> studentLogin(
    String username, 
    String password
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/student/lms/login/');
      print('🎓 Student Login URL: $url');
      
      final response = await http.post(
        url,
        body: json.encode({
          'username': username,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 Student Login Response Status: ${response.statusCode}');
      print('📦 Student Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Store student tokens separately
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_access_token', data['tokens']['access']);
        await prefs.setString('student_refresh_token', data['tokens']['refresh']);
        await prefs.setString('student_data', json.encode(data['student']));
        
        // Set static variable
        studentAccessToken = data['tokens']['access'];
        
        print('✅ Student login successful');
        return {
          'success': true,
          'student': data['student'],
          'tokens': data['tokens']
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Student login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Student login error: $e');
      rethrow;
    }
  }

  // Get Student Dashboard Data
  static Future<Map<String, dynamic>> getStudentDashboard() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/dashboard/');
      final headers = await _getStudentHeaders();
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load student dashboard: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Student dashboard error: $e');
      rethrow;
    }
  }

  // Get Student Course Details
  static Future<Map<String, dynamic>> getStudentCourse() async {
    try {
      final url = Uri.parse('$baseUrl/api/student/my-course/');
      final headers = await _getStudentHeaders();
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load student course: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Student course error: $e');
      rethrow;
    }
  }

  // Check if student is logged in
  static Future<bool> isStudentLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentData = prefs.getString('student_data');
      final accessToken = prefs.getString('student_access_token');
      
      return studentData != null && accessToken != null;
    } catch (e) {
      return false;
    }
  }

  // Student Logout
  static Future<void> studentLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('student_access_token');
      await prefs.remove('student_refresh_token');
      await prefs.remove('student_data');
      studentAccessToken = null;
      print('✅ Student logout successful');
    } catch (e) {
      print('❌ Student logout error: $e');
    }
  }

}
