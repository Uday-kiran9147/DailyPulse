import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entries = provider.entries.reversed.take(30).toList();

    final spots = entries
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.score.toDouble()))
        .toList();

    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────── Header ─────────
              Text(
                'Mood Insights',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Updated ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                style: TextStyle(
                  color: textColor.withValues(alpha:0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),

              // ───────── Stats Cards ─────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    context,
                    label: 'Total Days',
                    value: provider.totalEntries.toString(),
                    icon: Icons.calendar_month,
                    color: colorScheme.primary,
                  ),
                  _buildStatCard(
                    context,
                    label: 'Positive',
                    value:
                        '${((provider.positiveDays / (provider.totalEntries == 0 ? 1 : provider.totalEntries)) * 100).toStringAsFixed(0)}%',
                    icon: Icons.sentiment_satisfied_alt,
                    color: Colors.greenAccent,
                  ),
                  _buildStatCard(
                    context,
                    label: 'Negative',
                    value:
                        '${((provider.negativeDays / (provider.totalEntries == 0 ? 1 : provider.totalEntries)) * 100).toStringAsFixed(0)}%',
                    icon: Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ───────── Line Chart ─────────
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1C1C1C), const Color(0xFF171717)]
                        : [Colors.white, const Color(0xFFE9EDF0)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha:0.4)
                          : Colors.grey.withValues(alpha:0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: spots.isEmpty
                    ? Center(
                        child: Text(
                          'Not enough data to show chart.',
                          style: TextStyle(color: textColor.withValues(alpha:0.6)),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 5.5,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  final moods = ['😭', '😟', '😐', '🙂', '😄'];
                                  if (value > 0 && value <= 5) {
                                    return Text(
                                      moods[value.toInt() - 1],
                                      style: const TextStyle(fontSize: 16),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                getTitlesWidget: (value, _) {
                                  if (value % 5 == 0 &&
                                      value.toInt() < entries.length) {
                                    final date = entries[value.toInt()].date;
                                    return Text(
                                      DateFormat.Md().format(date),
                                      style: TextStyle(
                                        color: textColor.withValues(alpha:0.6),
                                        fontSize: 10,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              spots: spots,
                              color: colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colorScheme.primary.withValues(alpha:0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              // ───────── Common Mood Section ─────────
              if (provider.totalEntries > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
                          : [Colors.white, const Color(0xFFE8EAF6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha:0.3)
                            : Colors.grey.withValues(alpha:0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Most Common Mood',
                        style: TextStyle(
                          color: textColor.withValues(alpha:0.7),
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            provider.mostCommonMoodLabel,
                            style: TextStyle(fontSize: 22, color: textColor),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            provider.mostCommonMood,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.white;

    return Container(
      width: 95,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2B2B2B)]
              : [Colors.white, const Color(0xFFECEFF1)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.4)
                : Colors.grey.withValues(alpha:0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: textColor.withValues(alpha:0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
