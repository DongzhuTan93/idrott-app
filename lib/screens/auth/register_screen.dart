import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../components/back_button.dart';
import '../../components/custom_text_field.dart';
import '../../components/primary_button.dart';
import '../../components/profile_icon.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Simple registration logic - in a real app this would connect to a backend
      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      developer.log(
        'Registration attempt: $username / $email / ${password.length} chars',
        name: 'RegisterScreen',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing registration...')),
      );

      // Navigate to admin dashboard after registration
      Navigator.pushReplacementNamed(context, '/admin');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Build the desktop version layout
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side with back button
        Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 24.0),
          child: CustomBackButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ),

        // Main content area that takes up most of the space
        Expanded(
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              constraints: const BoxConstraints(maxWidth: 800),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Text(
                      'REGISTER',
                      style: AppTextStyles.headerStyle.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Container(width: 180, height: 1, color: AppColors.white),
                    const SizedBox(height: 40),

                    // Profile icon
                    const ProfileIcon(size: 120),
                    const SizedBox(height: 50),

                    // Input fields
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'USERNAME',
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          CustomTextField(
                            label: 'ENTER YOUR EMAIL',
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          CustomTextField(
                            label: 'PASSWORD',
                            controller: _passwordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Register button
                    SizedBox(
                      width: 200,
                      child: PrimaryButton(
                        text: 'REGISTER',
                        onPressed: _handleRegister,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Login link
                    GestureDetector(
                      onTap: _navigateToLogin,
                      child: Column(
                        children: [
                          Text(
                            'LOGIN',
                            style: AppTextStyles.linkStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 160,
                            height: 1,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build the mobile version layout
  Widget _buildMobileLayout() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Back button with proper padding
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: CustomBackButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ),
        ),

        // Main container with space for future bottom navigation
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: screenHeight * 0.04, // Slightly more top space
              bottom:
                  screenHeight * 0.08, // More bottom space for future home icon
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight *
                        0.7, // Adjusted to account for bottom space
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Top section
                          Column(
                            children: [
                              Text(
                                'REGISTER',
                                style: AppTextStyles.headerStyle,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 135,
                                height: 1,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Profile icon
                          const ProfileIcon(size: 80),
                          const SizedBox(height: 30),

                          // Form fields
                          Column(
                            children: [
                              CustomTextField(
                                label: 'USERNAME',
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                label: 'ENTER YOUR EMAIL',
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                label: 'PASSWORD',
                                controller: _passwordController,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Mobile register layout: Add more space around the button
                          const SizedBox(height: 50),

                          // Buttons and links
                          Column(
                            children: [
                              PrimaryButton(
                                text: 'REGISTER',
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: 50),
                              GestureDetector(
                                onTap: _navigateToLogin,
                                child: Column(
                                  children: [
                                    Text(
                                      'LOGIN',
                                      style: AppTextStyles.linkStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 136,
                                      height: 1,
                                      color: AppColors.white,
                                    ),
                                  ],
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800; // Adjusted breakpoint for desktop

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }
}
