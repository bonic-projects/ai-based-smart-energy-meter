import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/notification_data.dart';
import 'notification_viewmodel.dart';

class NotificationView extends StatefulWidget {
  final NotificationViewModel viewModel;

  NotificationView({required this.viewModel});

  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    // Schedule markAsRead() to run after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.markAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC8DBFF),
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              widget.viewModel.clearNotifications();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.viewModel.notifications.length,
        itemBuilder: (context, index) {
          final notification = widget.viewModel.notifications[index];
          return NotificationWidget(notification: notification);
        },
      ),
    );
  }
}

class NotificationWidget extends StatelessWidget {
  final NotificationData notification;

  NotificationWidget({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(notification.title),
        subtitle: Text(notification.description),
        trailing: Text(
          DateFormat('HH:mm').format(notification.timestamp),
        ),
      ),
    );
  }
}