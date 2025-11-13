import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/api/auth_provider.dart';
import 'package:techcadd/models/staff_model.dart';
import 'package:techcadd/views/admin_dashboard.dart';
// import 'package:techcadd/views/admin_login.dart';
import 'package:techcadd/views/staff/staff_dashboard_screen.dart';
import 'package:techcadd/views/student_registration/student_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp( MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: const MyApp(),
    ),);
  } catch (e) {
    debugPrint('Error setting orientation: $e');
    
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFFF8F9FA), 
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.dark, 
    ),
  );
    runApp(const MyApp());
  }
}

class MyAppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      // Perform cleanup when app is being destroyed or going to background
      ApiService.staffLogoutOnAppClose();
    }
  }
}
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // gradient ke liye transparent
        statusBarIconBrightness: Brightness.dark, // ya Brightness.light
        systemNavigationBarColor: Color(0xFFF8F9FA), // bottom bar
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Tech Login',
        //light theme
        theme: ThemeData(
          // brightness: Brightness.light,
          fontFamily: 'SF Pro Display',
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          primaryColor: const Color(0xFF282C5C),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF282C5C),
            secondary: Color(0xFF282C5C),
          ),
        ),
        darkTheme: ThemeData(
          // brightness: Brightness.dark,
          fontFamily: 'SF Pro Display',
          scaffoldBackgroundColor: const Color(0xFF282C5C),
          primaryColor: const Color(0xFFF8F9FA),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF8F9FA),
            secondary: Color(0xFFF8F9FA),
          ),
        ),
        themeMode: ThemeMode.light,
        home: const LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _loading=true;
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

final TextEditingController _staffUsernameController = TextEditingController();
final TextEditingController _staffPasswordController = TextEditingController();
  int selectedIndex = 0;
  int oldIndex = 0;

  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  final List<String> userTypes = ['Student', 'Employer', 'Admin'];
  final List<IconData> userIcons = [
    Icons.school,
    Icons.business,
    Icons.admin_panel_settings,
  ];
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoController.forward();
  }
  
// Update the _checkLoginStatus method in login screen
Future<void> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
   final isStudentLoggedIn = await ApiService.isStudentLoggedIn();
  if (isStudentLoggedIn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StudentDashboardScreen()),
    );
    return;
  }

 

  // Check staff auto-login - respect auto-logout setting
  final shouldAutoLogout = prefs.getBool('staff_auto_logout') ?? true;
  
  if (!shouldAutoLogout) {
    // Auto-logout disabled, check if staff is logged in
    final isStaffLoggedIn = await ApiService.isStaffLoggedIn();
    if (isStaffLoggedIn) {
      try {
        final staff = await ApiService.getStaffProfile();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StaffDashboardScreen(staff: staff),
          ),
        );
        return;
      } catch (e) {
        print('❌ Staff auto-login failed: $e');
        await ApiService.staffLogout();
      }
    }
  } else {
    // Auto-logout enabled, clear any existing staff data
    await ApiService.staffLogoutOnAppClose();
  }

  // no auto-login
  setState(() {
    _loading = false;
  });
}


  @override
  void dispose() {
    _logoController.dispose();
    _regController.dispose();
    _passController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
final TextEditingController _staffUsernameController = TextEditingController();
final TextEditingController _staffPasswordController = TextEditingController();

    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index != selectedIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        oldIndex = selectedIndex;
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 36),

                // Animated Welcome Text
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF282C5C), Color(0xFF282C5C)],
                            ).createShader(bounds),
                            child: const Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue to your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Image.asset(
                  "assets/images/techcaddLogo.png",
                  width: 240,
                  height: 69,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 20),

                // Tab Selector
                AnimatedUserTypeSelector(
                  userTypes: userTypes,
                  userIcons: userIcons,
                  selectedIndex: selectedIndex,
                  onTabChanged: _onTabChanged,
                ),

                const SizedBox(height: 30),

                // Swipeable Content Area with PageTransitionSwitcher
                // Swipeable Content Area (NO animation, instant switch)
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0 && selectedIndex > 0) {
                      _onTabChanged(selectedIndex - 1);
                    } else if (details.primaryVelocity! < 0 &&
                        selectedIndex < userTypes.length - 1) {
                      _onTabChanged(selectedIndex + 1);
                    }
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(selectedIndex),
                    child: _buildContent(),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _buildStudentForm();
      case 1:
        return _buildEmployerForm();
      case 2:
        return _buildAdminForm();
      default:
        return _buildStudentForm();
    }
  }

  // ------------------- Forms -------------------

  Widget _buildStudentForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formHeader(Icons.school, 'Student Login'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Registration Number',
                controller: _regController,
                icon: Icons.badge,
                hintText: 'Enter Registration Number',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Password',
                icon: Icons.lock,
                hintText: 'Enter your password',
                isPassword: true,
                controller: _passController
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => HapticFeedback.lightImpact(),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF282C5C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _buildStudentSignInButton(),
              SizedBox(height: 10),
              // Center(child: _buildNewRegistrationButton()),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildEmployerForm() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formHeader(Icons.business, 'Staff Login'),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Username',
              controller: _staffUsernameController,
              icon: Icons.person,
              hintText: 'Enter your username',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Password',
              controller: _staffPasswordController,
              icon: Icons.lock,
              hintText: 'Enter your password',
              isPassword: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => HapticFeedback.lightImpact(),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF282C5C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildStaffSignInButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildAdminForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formHeader(Icons.admin_panel_settings, 'Admin Access'),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.account_tree,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  hint: Text(
                    'Select Branch',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Jalandhar-I',
                      child: const Text('Jalandhar-I'),
                    ),
                    DropdownMenuItem(
                      value: 'Jalandhar-II',
                      child: const Text('Jalandhar-II'),
                    ),
                    DropdownMenuItem(
                      value: 'Phagwara',
                      child: const Text('Phagwara'),
                    ),
                    DropdownMenuItem(
                      value: 'Hoshiarpur',
                      child: const Text('Hoshiarpur'),
                    ),
                    DropdownMenuItem(
                      value: 'Ludhiana',
                      child: const Text('Ludhiana'),
                    ),
                    DropdownMenuItem(
                      value: "Chandigarh",
                      child: const Text("Chandigarh"),
                    ),
                  ],
                  onChanged: (value) => HapticFeedback.lightImpact(),
                ),
              ),
              const SizedBox(height: 20),
              
                    _buildTextField(
                      label: 'Username',
                      controller: _usernameController,
                      icon: Icons.person,
                      hintText: 'Enter your username',
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    _buildTextField(
                      label: 'Password',
                      controller: _passwordController,
                      icon: Icons.lock,
                      hintText: 'Enter your password',
                      isPassword: true,
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _buildLoginButton(context),

                    const SizedBox(height: 20),

                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.errorMessage.isNotEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red[400]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.errorMessage,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () => authProvider.clearError(),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }


  
  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF282C5C), Color(0xFF282C5C)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF282C5C).withAlpha(26),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        // In your login button onPressed
onPressed: () async {
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  setState(() => _isLoading = true);
  
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.login(username, password);
  
  if (success) {
    // DEBUG: Check tokens immediately after login
    await ApiService.debugStoredTokens();
    
    // Try to get profile to verify token works
    try {
      final profile = await ApiService.getAdminProfile();
      print('✅ Profile fetched successfully after login');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminMobileConsole()),
      );
    } catch (e) {
      print('❌ Profile fetch failed after login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful but token issue: $e')),
      );
    }
  }
  
  setState(() => _isLoading = false);
},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }



  Widget _formHeader(IconData icon, String title) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF282C5C), size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF282C5C),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    required String hintText,
    bool isPassword = false,
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          child: TextField(
            obscureText: isPassword,
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(icon, color: const Color(0xFF282C5C)),
              contentPadding: const EdgeInsets.all(13),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentSignInButton() {
  return Column(
    children: [
      Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF282C5C), Color(0xFF282C5C)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF282C5C).withAlpha(26),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            HapticFeedback.lightImpact();
            final username = _regController.text.trim();
            final password = _passController.text.trim();

            if (username.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            try {
              setState(() => _isLoading = true);
              
              final response = await ApiService.studentLogin(username, password);
              
              if (response['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Student login successful!')),
                );
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDashboardScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid username or password')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed: ${e.toString()}')),
              );
            } finally {
              setState(() => _isLoading = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      
      // Loader
      if (_isLoading) ...[
        SizedBox(height: 20),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF282C5C)),
        ),
        SizedBox(height: 10),
        Text(
          'Signing in...',
          style: TextStyle(
            color: Color(0xFF282C5C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ],
  );
}


Widget _buildStaffSignInButton() {
  return Column(
    children: [
      Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF282C5C), Color(0xFF282C5C)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF282C5C).withAlpha(26),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            HapticFeedback.lightImpact();
            final username = _staffUsernameController.text.trim();
            final password = _staffPasswordController.text.trim();

            if (username.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            try {
              setState(() => _loading = true);
              
              final response = await ApiService.staffLogin(username, password);
              
              if (response['success'] == true) {
                final staffData = response['staff'];
                final staff = StaffProfile.fromJson(staffData);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Staff login successful!')),
                );
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffDashboardScreen(staff: staff),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid username or password')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed: ${e.toString()}')),
              );
            } finally {
              setState(() => _loading = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      
      // Loader below the form (like admin login)
      if (_loading) ...[
        const SizedBox(height: 20),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF282C5C)),
        ),
        const SizedBox(height: 10),
        const Text(
          'Signing in...',
          style: TextStyle(
            color: Color(0xFF282C5C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ],
  );
}
  

  
}



class AnimatedUserTypeSelector extends StatefulWidget {
  final List<String> userTypes;
  final List<IconData> userIcons;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const AnimatedUserTypeSelector({
    super.key,
    required this.userTypes,
    required this.userIcons,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  State<AnimatedUserTypeSelector> createState() =>
      _AnimatedUserTypeSelectorState();
}

class _AnimatedUserTypeSelectorState extends State<AnimatedUserTypeSelector> {
  @override
  Widget build(BuildContext context) {
    final tabWidth = (MediaQuery.of(context).size.width - 32) / 3;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: tabWidth * widget.selectedIndex,
            top: 0,
            bottom: 0,
            child: Container(
              width: tabWidth,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF282C5C), Color(0xFF282C5C)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF282C5C).withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: widget.userTypes.asMap().entries.map((entry) {
              int index = entry.key;
              String userType = entry.value;
              IconData icon = widget.userIcons[index];
              bool isSelected = index == widget.selectedIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isSelected) widget.onTabChanged(index);
                  },
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 16,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              child: Text(userType),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
