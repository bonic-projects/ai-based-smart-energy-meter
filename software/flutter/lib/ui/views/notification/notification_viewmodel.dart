import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';

import '../../../models/notification_data.dart';
import '../../../services/firestore_service.dart';

class NotificationViewModel extends ReactiveViewModel {
  final FirestoreService _firestoreService = FirestoreService();
  List<NotificationData> _notifications = [];
  List<NotificationData> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationViewModel() {
    _loadNotifications();
  }

  void _loadNotifications() {
    _firestoreService.getNotifications().listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });
  }

  void addNotification(String title, String description) async {
    final notification = NotificationData(
      title: title,
      description: description,
      timestamp: DateTime.now(),
    );
    await _firestoreService.saveNotification(notification);
    notifyListeners();
  }

  void markAsRead() async {
    for (final notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        await _firestoreService.markNotificationAsRead(notification);
      }
    }
    notifyListeners();
  }

  void clearNotifications() async {
    await _firestoreService.clearNotifications();
    _notifications.clear();
    notifyListeners();
  }
}
