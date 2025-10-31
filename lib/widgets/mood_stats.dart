import 'package:dailyplus/providers/mood_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoodStats extends StatelessWidget {
  const MoodStats({super.key, required this.provider});

  final MoodProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.white;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: provider.totalEntries > 0 ? 1.0 : 0.6,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20).r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF1E1E1E), const Color(0xFF232526)]
                : [Colors.white, const Color(0xFFF0F4F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20).r,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Your Mood Stats",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),

            // Total Days Logged
            _buildStatRow(
              context,
              icon: Icons.calendar_today,
              iconColor: Colors.amber,
              label: "Total Days Logged:",
              value: provider.totalEntries.toString(),
            ),

            SizedBox(height: 12.h),

            // Positive Days
            _buildProgressStat(
              context,
              icon: Icons.sentiment_satisfied_alt,
              iconColor: Colors.greenAccent,
              label: "Positive Days",
              value: provider.totalEntries == 0
                  ? 0.toStringAsFixed(0)
                  : ((provider.positiveDays / provider.totalEntries) * 100)
                      .toStringAsFixed(0),
              progress: provider.totalEntries == 0
                  ? 0
                  : provider.positiveDays / provider.totalEntries,
              progressColor: Colors.greenAccent,
            ),

            SizedBox(height: 16.h),

            // Most Common Mood
            Row(
              children: [
                Icon(Icons.mood, color: colorScheme.primary, size: 22),
                SizedBox(width: 10.w),
                Text(
                  "Most Common Mood:",
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      provider.mostCommonMood,
                      style: TextStyle(
                        fontSize: 22,
                        color: textColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      provider.mostCommonMoodLabel,
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final textColor = Theme.of(context).textTheme.titleLarge?.color ?? Colors.white;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double progress,
    required Color progressColor,
  }) {
    final textColor = Theme.of(context).textTheme.titleLarge?.color ?? Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12.sp,
              ),
            ),
            const Spacer(),
            Text(
              "$value%",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    );
  }
}
