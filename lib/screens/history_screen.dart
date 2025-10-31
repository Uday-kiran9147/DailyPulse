
import 'package:dailyplus/widgets/history_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/mood_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          TableCalendar(
            focusedDay: _focused,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selected, day),
            onDaySelected: (sel, foc) {
              setState(() {
                _selected = sel;
                _focused = foc;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final entry = provider.entryForDate(day);
                return entry != null ? Center(child: Text(entry.emoji)) : null;
              },
            ),
          ),
          SizedBox(height: 10.h),
          if (provider.entries.isEmpty)
            Padding(
              padding: EdgeInsets.all(20).r,
              child: Text('No entries yet. Start logging your moods!'),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.entries.length,
                itemBuilder: (context, i) {
                  final reversed = provider.entries.reversed.toList();
                  final e = reversed[i];
                  return HistoryTile(e: e, provider: provider);
                },
              ),
            ),
        ],
      ),
    );
  }
}
