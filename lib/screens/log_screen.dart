import 'package:dailyplus/providers/theme_provider.dart';
import 'package:dailyplus/widgets/mood_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> with TickerProviderStateMixin {
  String? _selectedEmoji;
  int? _selectedScore;
  final _noteController = TextEditingController();
  bool _isSaving = false;
  late final AnimationController _pulseController;

  final emojiOptions = [
    {'emoji': '😄', 'label': 'Joyful', 'score': 5},
    {'emoji': '🙂', 'label': 'Good', 'score': 4},
    {'emoji': '😐', 'label': 'Stressed', 'score': 3},
    {'emoji': '😟', 'label': 'Sad', 'score': 2},
    {'emoji': '😭', 'label': 'Very Sad', 'score': 1},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedEmoji == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<MoodProvider>(context, listen: false);
      final now = DateTime.now();
      final entry = MoodEntry(
        date: DateTime(now.year, now.month, now.day),
        emoji: _selectedEmoji!,
        note: _noteController.text.trim(),
        score: _selectedScore ?? 3,
      );
      await provider.addEntry(entry);
      if (mounted) {
        _noteController.clear();
        _selectedEmoji = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DailyPulse saved successfully!')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final now = DateTime.now();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      key: const ValueKey('LogScreen'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${DateFormat.MMMM().format(now)} ${now.day}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Provider.of<ThemeProvider>(context).isDarkMode
                          ? Icons.wb_sunny_outlined
                          : Icons.nights_stay_outlined,
                      color: colorScheme.primary,
                    ),
                    onPressed: () async {
                      await context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                ],
              ),
              Text(
                DateFormat('EEEE').format(now),
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color?.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 28.h),

              // Emoji selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: emojiOptions.map((e) {
                    final isSelected = _selectedEmoji == e['emoji'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = e['emoji'] as String;
                          _selectedScore = e['score'] as int;
                        });
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: isSelected ? 1.3 : 1.0,
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: EdgeInsets.all(8).r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.5,
                                      ),
                                      blurRadius: 12,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            e['emoji'] as String,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 36.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 30.h),

              // Note input
              TextFormField(
                maxLength: 60,
                controller: _noteController,
                maxLines: 5,
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Describe your day... (optional)',
                  hintStyle: TextStyle(
                    color: theme.textTheme.titleLarge?.color?.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 30.h),

              // Save button with animation
              GestureDetector(
                onTap: _isSaving ? null : _saveMood,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final t = _pulseController.value;
                    final pulse = 0.98 + 0.04 * (1 - (t - 0.5).abs() * 2);
                    return Transform.scale(
                      scale: pulse,
                      child: Container(
                        width: double.infinity,
                        height: 55.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7F7FD5),
                              Color(0xFF86A8E7),
                              Color(0xFF91EAE4),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Save DailyPulse',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 30.h),

              MoodStats(provider: provider),
            ],
          ),
        ),
      ),
    );
  }
}
