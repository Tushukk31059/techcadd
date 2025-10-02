import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:techcadd/employeeform.dart';
import 'package:techcadd/qr_service.dart';
import 'package:techcadd/validate.dart';
// import 'video_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error setting orientation: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      themeMode: ThemeMode.dark,
      home: const LoginScreen(),
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
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
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
                              colors: [
                                Color(0xFF282C5C),
                                Color.fromARGB(255, 40, 44, 92),
                              ],
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
                const SizedBox(height: 28),
                Image.asset(
                  'assets/images/techcadd.png',
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
                // Swipeable Content Area
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

  Widget _buildStudentForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      color: Color(0xFF282C5C),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Student Login',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF282C5C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Registration Number',
                icon: Icons.badge,
                hintText: 'Enter Registration Number',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Password',
                icon: Icons.lock,
                hintText: 'Enter your password',
                isPassword: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFF282C5C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _buildSignInButton(),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _buildNewRegistrationButton(),
      ],
    );
  }

  Widget _buildEmployerForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.business,
                      color: Color(0xFF282C5C),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Employer Login',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF282C5C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email Address',
                icon: Icons.email,
                hintText: 'Enter your email address',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Password',
                icon: Icons.lock,
                hintText: 'Enter your password',
                isPassword: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: const Color(0xFF282C5C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _buildSignInButton(),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _buildNewEmpRegistrationButton(),
      ],
    );
  }

  Widget _buildAdminForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF282C5C),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admin Access',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF282C5C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: const Icon(
                      Icons.account_tree,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                  hint: Text(
                    'Select Branch',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  items: [
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
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
              const SizedBox(height: 32),
              _buildSignInButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
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

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF282C5C), Color.fromARGB(255, 47, 82, 121)],
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
        onPressed: () {
          HapticFeedback.lightImpact();
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
    );
  }

  Widget _buildNewRegistrationButton() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentFormPage()),
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_add, color: Color(0xFF282C5C), size: 20),
          const SizedBox(width: 8),
          Text(
            'New Registration? Click here',
            style: TextStyle(
              color: const Color(0xFF282C5C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewEmpRegistrationButton() {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRScan()),
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_add, color: Color(0xFF282C5C), size: 20),
          const SizedBox(width: 8),
          Text(
            'Not Registered? Click here',
            style: TextStyle(
              color: const Color(0xFF282C5C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

class _AnimatedUserTypeSelectorState extends State<AnimatedUserTypeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    if (index != widget.selectedIndex) {
                      widget.onTabChanged(index);
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 18,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                //top navigation button size
                                fontSize: 18,
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
