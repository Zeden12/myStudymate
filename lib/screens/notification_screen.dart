import 'package:flutter/material.dart';
import 'package:mystudymate/db/helpers/notification_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/notification_model.dart' as CustomNotification;

class NotificationScreen extends StatefulWidget {
  final int userId;

  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationHelper _notificationHelper;
  List<CustomNotification.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationHelper = NotificationHelper(DatabaseHelper.instance);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    _notifications = await _notificationHelper.getNotificationsByUser(widget.userId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          Icons.notifications,
                          color: notification.isRead ? Colors.grey : Colors.green[700],
                        ),
                        title: Text(
                          notification.message,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          () {
                            final createdAt = DateTime.parse(notification.createdAt);
                            return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
                          }(),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          onPressed: () async {
                            await _notificationHelper
                                .deleteNotification(notification.id!);
                            _loadNotifications();
                          },
                        ),
                        onTap: () async {
                          if (!notification.isRead) {
                            await _notificationHelper
                                .markAsRead(notification.id!);
                            _loadNotifications();
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}