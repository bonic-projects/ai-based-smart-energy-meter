import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationData>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationData.fromMap(doc.data()))
        .toList());
  }

  Future<void> saveNotification(NotificationData notification) async {
    await _firestore.collection('notifications').add({
      'title': notification.title,
      'description': notification.description,
      'timestamp': Timestamp.fromDate(notification.timestamp),
      'isRead': notification.isRead,
    });
  }

  Future<void> markNotificationAsRead(NotificationData notification) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('timestamp', isEqualTo: Timestamp.fromDate(notification.timestamp))
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> clearNotifications() async {
    final snapshot = await _firestore.collection('notifications').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
