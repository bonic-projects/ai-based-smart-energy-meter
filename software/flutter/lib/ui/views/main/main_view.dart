// First, create a new widget that will hold the bottom navigation and pages
import 'package:ai_based_smart_energy_meter/ui/components/customappbar.dart';
import 'package:ai_based_smart_energy_meter/ui/views/devices/devices_view.dart';
import 'package:ai_based_smart_energy_meter/ui/views/home/home_view.dart';
import 'package:ai_based_smart_energy_meter/ui/views/main/main_viewmodel.dart';
import 'package:ai_based_smart_energy_meter/ui/views/notification/notification_viewmodel.dart';
import 'package:ai_based_smart_energy_meter/ui/views/predict/predict_view.dart';
import 'package:ai_based_smart_energy_meter/ui/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainViewModel>.reactive(
      viewModelBuilder: () => MainViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar(notificationViewModel: NotificationViewModel(),),
        body: Stack(
          children: [
            PageView(
              controller: model.pageController,
              onPageChanged: model.setIndex,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              children: [
                const HomeView(),
                const PredictView(),
                DevicesView(),
                ProfileView(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(model),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(MainViewModel model) {
    return BottomNavigationBar(
      currentIndex: model.currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      onTap: model.handleNavigation,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/reading.png',
            width: 35, // Adjust the size as needed
            height: 41,
            color: model.currentIndex == 0 ? Colors.blue : Colors.black, // Optional: Change color based on selection
          ),
          label: 'Readings',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/predict.png',
            width: 35 ,
            height: 41,
            color: model.currentIndex == 1 ? Colors.blue : Colors.black,
          ),
          label: 'Predict',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/device.png',
            width: 35,
            height: 41,
            color: model.currentIndex == 2 ? Colors.blue : Colors.black,
          ),
          label: 'Devices',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/account.png',
            width: 35,
            height: 41,
            color: model.currentIndex == 3 ? Colors.blue : Colors.black,
          ),
          label: 'Account',
        ),
      ],
    );
  }
}
