import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

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

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  Map<DateTime, List<Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _dataService = DataService(Supabase.instance.client);
    _eventsFuture = _loadEvents();
  }

  Future<List<Event>> _loadEvents() async {
    final events = await _dataService.getUpcomingEvents();
    _eventsByDay = _groupEvents(events);
    _selectedDay = DateTime.now();
    return events;
  }

  Map<DateTime, List<Event>> _groupEvents(List<Event> events) {
    final map = <DateTime, List<Event>>{};
    for (final e in events) {
      final day = DateTime(
        e.startDate.year,
        e.startDate.month,
        e.startDate.day,
      );
      map.putIfAbsent(day, () => []);
      map[day]!.add(e);
    }
    return map;
  }

  List<Event> _eventsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _eventsByDay[d] ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("FBLA Calendar"), elevation: 0),

      // NO FAB → read‑only
      floatingActionButton: null,

      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            );
          }

          return Column(
            children: [
              _buildCalendar(),
              const SizedBox(height: 4),
              Expanded(child: _buildEventSheet()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Material(
      elevation: 2,
      child: TableCalendar<Event>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            _selectedDay != null &&
            day.year == _selectedDay!.year &&
            day.month == _selectedDay!.month &&
            day.day == _selectedDay!.day,
        calendarFormat: _format,
        eventLoader: _eventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,

        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false, // prevents user from toggling formats
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),

        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersMaxCount: 3,
        ),

        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },

        onPageChanged: (focused) {
          _focusedDay = focused;
        },
      ),
    );
  }

  Widget _buildEventSheet() {
    final events = _selectedDay != null ? _eventsForDay(_selectedDay!) : [];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: events.isEmpty
          ? Center(
              child: Text(
                "No events on this day",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            )
          : ListView.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = events[i];
                return _buildEventTile(e);
              },
            ),
    );
  }

  Widget _buildEventTile(Event e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _categoryColor(e.category).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _categoryColor(e.category).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 60,
            decoration: BoxDecoration(
              color: _categoryColor(e.category),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 6),
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
                      "${e.startDate.month}/${e.startDate.day} "
                      "${e.startDate.hour}:${e.startDate.minute.toString().padLeft(2, '0')}",
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
