import 'package:flutter/material.dart';
import '../../components/back_button.dart';
import '../../components/primary_button.dart';
import '../../theme/colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "JESPER",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                thickness: 1,
                                indent: 100,
                                endIndent: 100,
                              ),

                              const Spacer(),

                              PrimaryButton(
                                text: 'ADD NEW USER',
                                width: double.infinity,
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/admin/add-user',
                                    ),
                              ),
                              const SizedBox(height: 30),
                              PrimaryButton(
                                text: 'ALL USERS',
                                width: double.infinity,
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/admin/users',
                                    ),
                              ),
                              const SizedBox(height: 30),
                              PrimaryButton(
                                text: 'SETTING',
                                width: double.infinity,
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/admin/settings',
                                    ),
                              ),

                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.home,
                              color: Color(0xFFFFE000),
                              size: 32,
                            ),
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/',
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/admin',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
