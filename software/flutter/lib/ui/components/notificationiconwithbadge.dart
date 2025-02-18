import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../views/notification/notification_view.dart';
import '../views/notification/notification_viewmodel.dart';

class NotificationIconWithBadge extends StatelessWidget {
  final NotificationViewModel viewModel;

  NotificationIconWithBadge({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationViewModel>.reactive(
      viewModelBuilder: () => viewModel,
      builder: (context, viewModel, child) {
        return badges.Badge(
          badgeContent: Text(
            viewModel.unreadCount.toString(), // Display unread count
            style: TextStyle(color: Colors.white),
          ),
          showBadge: viewModel.unreadCount > 0, // Show badge only if unread notifications exist
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(6),
          ),
          position: badges.BadgePosition.topEnd(top: 1, end: 5),
          child: IconButton(
            icon: Icon(Icons.notifications,size: 30,),
            onPressed: () {
              // Navigate to the notification page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationView(viewModel: viewModel),
                ),
              );
              viewModel.markAsRead(); // Mark notifications as read
            },
          ),
        );
      },
    );
  }
}