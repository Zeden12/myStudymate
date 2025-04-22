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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          Icons.notifications,
                          color: notification.isRead ? Colors.grey : Colors.green[700],
                          size: 28,
                        ),
                        title: Text(
                          notification.message,
                          style: TextStyle(
                            fontWeight: notification.isRead 
                                ? FontWeight.normal 
                                : FontWeight.bold,
                            color: notification.isRead 
                                ? Colors.grey[600] 
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(notification.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!notification.isRead)
                              IconButton(
                                icon: const Icon(Icons.mark_as_unread),
                                color: Colors.blue,
                                onPressed: () async {
                                  await _notificationHelper
                                      .markAsRead(notification.id!);
                                  _loadNotifications();
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red[300],
                              onPressed: () async {
                                await _notificationHelper
                                    .deleteNotification(notification.id!);
                                _loadNotifications();
                              },
                            ),
                          ],
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