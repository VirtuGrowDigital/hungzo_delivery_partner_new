import 'package:get/get.dart';

enum NotificationTab { all, unread, read }

class NotificationController extends GetxController {
  final selectedTab = NotificationTab.all.obs;

  /// Dummy notifications (can replace with API / Firebase)
  final notifications = <Map<String, dynamic>>[
    {
      "title": "New Notification",
      "body":
      "Far far away, behind the word mountains, far from the countries.",
      "isRead": false,
    },
    {
      "title": "Order Delivered",
      "body": "Your order has been delivered successfully.",
      "isRead": true,
    },
  ].obs;

  void changeTab(NotificationTab tab) {
    selectedTab.value = tab;
  }

  List<Map<String, dynamic>> get filteredNotifications {
    switch (selectedTab.value) {
      case NotificationTab.unread:
        return notifications.where((n) => n["isRead"] == false).toList();
      case NotificationTab.read:
        return notifications.where((n) => n["isRead"] == true).toList();
      default:
        return notifications;
    }
  }

  void markAsRead(Map<String, dynamic> item) {
    item["isRead"] = true;
    notifications.refresh();
  }
}
