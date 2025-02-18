import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationData {  // Renamed from Notification to NotificationData
  final String title;
  final String description;
  final DateTime timestamp;
  bool isRead;

  NotificationData({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
}