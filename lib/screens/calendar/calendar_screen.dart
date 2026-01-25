import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/event.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

enum CalendarMode { month, schedule }

class FblaCalendarScreen extends StatefulWidget {
  const FblaCalendarScreen({super.key});

  @override
  State<FblaCalendarScreen> createState() => _FblaCalendarScreenState();
}

class _FblaCalendarScreenState extends State<FblaCalendarScreen> {
  late final DataService _dataService;
  late Future<List<Event>> _eventsFuture;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  CalendarMode _mode = CalendarMode.month;
  String _selectedCategory = 'All';

  Map<DateTime, List<Event>> _eventsByDay = {};

  final List<String> _categories = [
    'All',
    'Meeting',
    'Competition',
    'Workshop',
    'Program',
  ];

  @override
  void initState() {
    super.initState();
    _dataService = DataService(Supabase.instance.client);
    _eventsFuture = _loadEvents();
  }

  Future<List<Event>> _loadEvents() async {
    final events = await _dataService.getUpcomingEvents();
    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    _eventsByDay = _groupEvents(events);
    _selectedDay = DateTime.now();
    return events;
  }

  Map<DateTime, List<Event>> _groupEvents(List<Event> events) {
    final map = <DateTime, List<Event>>{};
    for (final e in events) {
      final day = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      map.putIfAbsent(day, () => []);
      map[day]!.add(e);
    }
    return map;
  }

  List<Event> _eventsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final list = _eventsByDay[d] ?? [];
    if (_selectedCategory == 'All') return list;
    return list.where((e) => e.category == _selectedCategory).toList();
  }

  List<Event> _allEventsFiltered(List<Event> all) {
    if (_selectedCategory == 'All') return all;
    return all.where((e) => e.category == _selectedCategory).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Meeting':
        return Colors.blue;
      case 'Workshop':
        return Colors.orange;
      case 'Competition':
        return Colors.green;
      case 'Program':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $ampm";
  }

  String _formatDateHeader(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "FBLA Calendar",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            );
          }

          final allEvents = snapshot.data!;
          if (allEvents.isEmpty) {
            return const Center(child: Text("No upcoming events"));
          }

          return Column(
            children: [
              _buildHeaderBar(),
              _buildCategoryChips(),
              const SizedBox(height: 4),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _mode == CalendarMode.month
                      ? _buildMonthView()
                      : _buildScheduleView(allEvents),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Top bar with Month / Schedule toggle
  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            "${_focusedDay.month}/${_focusedDay.year}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          _buildModeChip("Month", CalendarMode.month),
          const SizedBox(width: 8),
          _buildModeChip("Schedule", CalendarMode.schedule),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, CalendarMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Category filter row
  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final isSelected = cat == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: AppTheme.primaryBlue,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Month view + events for selected day
  Widget _buildMonthView() {
    final events = _selectedDay != null ? _eventsForDay(_selectedDay!) : [];

    return Column(
      children: [
        SizedBox(
          height: 380, // FIXES OVERFLOW
          child: TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null &&
                day.year == _selectedDay!.year &&
                day.month == _selectedDay!.month &&
                day.day == _selectedDay!.day,
            eventLoader: _eventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
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
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) => _focusedDay = focused,
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Text(
                    "No events on this day",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, i) => _eventCard(events[i]),
                ),
        ),
      ],
    );
  }

  // Schedule (agenda) view
  Widget _buildScheduleView(List<Event> allEvents) {
    final filtered = _allEventsFiltered(allEvents);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No upcoming events",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final Map<DateTime, List<Event>> grouped = {};
    for (final e in filtered) {
      final day = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(e);
    }

    final dates = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final events = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "${date.month}/${date.day}/${date.year}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...events.map(_eventTimelineTile),
          ],
        );
      },
    );
  }

  // Card used in Month view list
  Widget _eventCard(Event e) {
    final color = _categoryColor(e.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(e.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(_formatTime(e.startDate),
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(e.location,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              e.category,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tile used in Schedule view timeline
  Widget _eventTimelineTile(Event e) {
    final color = _categoryColor(e.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 3, height: 60, color: color.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(e.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(_formatTime(e.startDate),
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(e.location,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      e.category,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}