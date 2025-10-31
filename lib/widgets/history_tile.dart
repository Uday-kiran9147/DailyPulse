
import 'dart:developer';

import 'package:dailyplus/models/mood_entry.dart';
import 'package:dailyplus/providers/mood_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatefulWidget {
  const HistoryTile({super.key, required this.e, required this.provider});

  final MoodEntry e;
  final MoodProvider provider;

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
            log('expanded: $isExpanded');
          });
        },
        leading: Text(widget.e.emoji, style: TextStyle(fontSize: 28.sp)),
        title: Text(DateFormat.yMMMd().format(widget.e.date)),
        subtitle: Text(
          widget.e.note.isEmpty ? 'No note' : widget.e.note,
          maxLines: isExpanded ? 10 : null,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => widget.provider.deleteEntry(widget.e.id ?? -1),
        ),
      ),
    );
  }
}
