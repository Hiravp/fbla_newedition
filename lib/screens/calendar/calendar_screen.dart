import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final DataService _dataService;
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _dataService = DataService(Supabase.instance.client);
    _eventsFuture = _loadEvents();
  }

  Future<List<Event>> _loadEvents() async {
    final events = await _dataService.getUpcomingEvents();
    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    return events;
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Meeting':
        return Colors.blue;
      case 'Workshop':
        return Colors.orange;
      case 'Competition':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Schedule"), elevation: 0),

      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            );
          }

          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text("No upcoming events"));
          }

          // Group events by date
          final Map<String, List<Event>> grouped = {};
          for (final e in events) {
            final key =
                "${e.startDate.month}/${e.startDate.day}/${e.startDate.year}";
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(e);
          }

          final dateKeys = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: dateKeys.length,
            itemBuilder: (context, index) {
              final date = dateKeys[index];
              final dayEvents = grouped[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Events for that date
                  ...dayEvents.map((e) => _buildEventTile(e)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventTile(Event e) {
    final color = _categoryColor(e.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Timeline Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),

          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(e.startDate),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
