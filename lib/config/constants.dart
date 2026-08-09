class AppConstants {
  static const String appName = 'SyncSpace';
  static const String adminEmail = 'risheesharma.fbd@gmail.com';
  static const bool useDemoData = true; // Set to false for real data
  
  // Request ID prefix
  static const String requestPrefix = 'SR';
  
  // Categories
  static const List<String> categories = [
    'UI update',
    'Event setup',
    'Bug fix',
    'Content change',
    'Other',
  ];
  
  // Priorities
  static const List<String> priorities = [
    'Normal',
    'High',
    'Urgent',
  ];
  
  // Statuses
  static const List<String> statuses = [
    'new',
    'in_progress',
    'waiting_on_client',
    'resolved',
  ];
  
  static String statusLabel(String status) {
    switch (status) {
      case 'new':
        return 'New';
      case 'in_progress':
        return 'In progress';
      case 'waiting_on_client':
        return 'Waiting on you';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }
  
  static String categoryIcon(String category) {
    switch (category) {
      case 'UI update':
        return '🎨';
      case 'Event setup':
        return '📅';
      case 'Bug fix':
        return '🔧';
      case 'Content change':
        return '✏️';
      default:
        return '💡';
    }
  }
}
