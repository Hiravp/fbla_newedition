import '../models/news.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../models/chat_message.dart';

class DataService {
  // Simulated data - in production, this would connect to a backend
  final List<News> _newsItems = [
    News(
      id: '1',
      title: 'FBLA National Conference 2024',
      content: 'Join us for the annual FBLA National Conference in San Francisco. Register now to secure your spot!',
      category: 'Events',
      publishedDate: DateTime.now().subtract(const Duration(days: 5)),
      author: 'FBLA Admin',
      imageUrl: 'https://via.placeholder.com/400x300?text=FBLA+Conference',
      views: 234,
    ),
    News(
      id: '2',
      title: 'New Business Case Study Released',
      content: 'The 2024 Business Law case study is now available. Download and start preparing for competition!',
      category: 'Resources',
      publishedDate: DateTime.now().subtract(const Duration(days: 3)),
      author: 'Education Team',
      imageUrl: 'https://via.placeholder.com/400x300?text=Case+Study',
      views: 156,
    ),
    News(
      id: '3',
      title: 'Member Spotlight: Sarah\'s Journey',
      content: 'Read about Sarah\'s incredible journey from local chapter member to national competition winner.',
      category: 'Member Stories',
      publishedDate: DateTime.now().subtract(const Duration(days: 1)),
      author: 'Community Team',
      imageUrl: 'https://via.placeholder.com/400x300?text=Member+Spotlight',
      views: 445,
    ),
  ];

  final List<Event> _events = [
    Event(
      id: '1',
      title: 'Local Chapter Meeting',
      description: 'Monthly chapter meeting to discuss upcoming events and competitions.',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7, hours: 2)),
      location: 'High School Auditorium',
      category: 'Meeting',
      organizerId: 'admin1',
      attendees: [],
    ),
    Event(
      id: '2',
      title: 'Competition Preparation Workshop',
      description: 'Learn tips and tricks to prepare for the business management competition.',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14, hours: 3)),
      location: 'Community Center',
      category: 'Workshop',
      organizerId: 'admin1',
      attendees: [],
    ),
    Event(
      id: '3',
      title: 'Regional Competition',
      description: 'Regional FBLA competition with multiple events and competitions.',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 31)),
      location: 'State University',
      category: 'Competition',
      organizerId: 'admin1',
      attendees: [],
    ),
  ];

  Future<List<News>> getNews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _newsItems;
  }

  Future<List<News>> getNewsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _newsItems.where((n) => n.category == category).toList();
  }

  Future<News?> getNewsById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _newsItems.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Event>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _events;
  }

  Future<List<Event>> getUpcomingEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return _events.where((e) => e.startDate.isAfter(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Future<Event?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addEvent(Event event) async {
    _events.add(event);
  }

  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
    }
  }

  Future<void> addNews(News news) async {
    _newsItems.add(news);
  }

  Future<List<User>> searchMembers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulated search results
    return [
      User(
        id: '1',
        name: 'Alice Johnson',
        email: 'alice@fbla.com',
        chapter: 'Downtown Chapter',
        bio: 'Business enthusiast and competition winner',
      ),
      User(
        id: '2',
        name: 'Bob Smith',
        email: 'bob@fbla.com',
        chapter: 'East Side Chapter',
        bio: 'Leadership and entrepreneurship focused',
      ),
    ];
  }

  Future<List<ChatMessage>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<void> saveChatMessage(ChatMessage message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In production, save to database
  }

  Future<List<String>> fetchItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Item 1', 'Item 2', 'Item 3'];
  }
}
