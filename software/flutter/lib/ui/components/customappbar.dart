import 'package:ai_based_smart_energy_meter/ui/views/notification/notification_view.dart';
import 'package:ai_based_smart_energy_meter/ui/views/notification/notification_viewmodel.dart';
import 'package:flutter/material.dart';

import 'notificationiconwithbadge.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NotificationViewModel notificationViewModel;
  const CustomAppBar({required this.notificationViewModel,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the status bar height
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AppBar(
      backgroundColor: const Color(0xFFC8DBFF), // Light blue background
      elevation: 0, // Remove shadow
      toolbarHeight:
          120 + statusBarHeight, // Adjust height to fit the images + status bar
      automaticallyImplyLeading: false, // Remove default back button
      actions: [
        NotificationIconWithBadge(viewModel: notificationViewModel),
      ],
      flexibleSpace: Padding(
        padding: EdgeInsets.only(
            top: statusBarHeight), // Add padding for the status bar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Center: Logo images
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/voltaura.png', // Path to "VA" image
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Image.asset(
                        'assets/images/logo.png', // Path to "VOLTAURA" image
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "-Empowering Smarter Energy Choices-",
                        style: TextStyle(
                          fontFamily:
                              'JimNightshade', // Ensure the font is loaded
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(120); // Adjusted height to fit logo images
}
