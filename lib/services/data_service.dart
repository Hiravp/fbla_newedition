import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news.dart';
import '../models/event.dart';
import '../models/user.dart' as fbla_user;
import '../models/chat_message.dart';

class DataService {
  late final SupabaseClient _supabase;

  DataService(SupabaseClient supabase) {
    _supabase = supabase;
  }

  // News Methods
  Future<List<News>> getNews() async {
    try {
      final data = await _supabase.from('news').select();
      return (data as List).map((item) => News.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching news: $e');
      return _getMockNews();
    }
  }

  Future<List<News>> getNewsByCategory(String category) async {
    try {
      final data = await _supabase
          .from('news')
          .select()
          .eq('category', category);
      return (data as List).map((item) => News.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching news by category: $e');
      return _getMockNews().where((n) => n.category == category).toList();
    }
  }

  // Event Methods
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final data = await _supabase
          .from('events')
          .select()
          .gte('start_date', DateTime.now().toIso8601String())
          .order('start_date', ascending: true);
      return (data as List).map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return _getMockEvents();
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final data = await _supabase
          .from('events')
          .select()
          .eq('id', id)
          .single();
      return Event.fromJson(data);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  // Member Methods
  Future<List<fbla_user.User>> searchMembers(String query) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .ilike('name', '%$query%');
      return (data as List).map((item) => fbla_user.User.fromJson(item)).toList();
    } catch (e) {
      print('Error searching members: $e');
      return [];
    }
  }

  // Chat Message Methods
  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      await _supabase.from('chat_messages').insert({
        'id': message.id,
        'content': message.content,
        'is_user': message.isUser,
        'timestamp': message.timestamp.toIso8601String(),
        'sender_id': message.senderId,
      });
    } catch (e) {
      print('Error saving chat message: $e');
    }
  }

  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final data = await _supabase
          .from('chat_messages')
          .select()
          .eq('sender_id', userId)
          .order('timestamp', ascending: false)
          .limit(50);
      return (data as List).map((item) {
        return ChatMessage(
          id: item['id'],
          content: item['content'],
          isUser: item['is_user'],
          timestamp: DateTime.parse(item['timestamp']),
          senderId: item['sender_id'],
        );
      }).toList().reversed.toList();
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }

  // Mock data fallback
  List<News> _getMockNews() {
    return [
      News(
        id: '1',
        title: 'FBLA National Conference 2024',
        content: 'Join us for the annual FBLA National Conference in San Francisco. Register now to secure your spot!',
        category: 'Events',
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        author: 'FBLA Admin',
        imageUrl: '',
        views: 234,
      ),
      News(
        id: '2',
        title: 'New Business Case Study Released',
        content: 'The 2024 Business Law case study is now available. Download and start preparing for competition!',
        category: 'Resources',
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        author: 'Education Team',
        imageUrl: '',
        views: 156,
      ),
      News(
        id: '3',
        title: 'Member Spotlight: Sarah\'s Journey',
        content: 'Read about Sarah\'s incredible journey from local chapter member to national competition winner.',
        category: 'Member Stories',
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Community Team',
        imageUrl: '',
        views: 445,
      ),
    ];
  }

  List<Event> _getMockEvents() {
    return [
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
  }
}
