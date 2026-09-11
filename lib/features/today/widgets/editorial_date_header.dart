import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class EditorialDateHeader extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onReturnToToday;

  const EditorialDateHeader({
    super.key,
    required this.selectedDate,
    required this.onReturnToToday,
  });

  @override
  State<EditorialDateHeader> createState() => _EditorialDateHeaderState();
}

class _EditorialDateHeaderState extends State<EditorialDateHeader> {
  Timer? _ticker;
  String _locationName = 'Local';

  @override
  void initState() {
    super.initState();
    _detectLocation();
    _ticker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _detectLocation() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final id = info.identifier;
      if (id.contains('/')) {
        final city = id.split('/').last.replaceAll('_', ' ');
        if (mounted) {
          setState(() {
            _locationName = city;
          });
        }
      } else if (id.isNotEmpty) {
        if (mounted) {
          setState(() {
            _locationName = id;
          });
        }
      }
    } catch (_) {
      // Keep 'Local' as fallback
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isToday = widget.selectedDate.year == now.year &&
        widget.selectedDate.month == now.month &&
        widget.selectedDate.day == now.day;

    final weekdayStr = DateFormat('EEEE').format(widget.selectedDate);
    final monthDayFullStr = DateFormat('d MMMM').format(widget.selectedDate);
    final dayNum = widget.selectedDate.day.toString().padLeft(2, '0');
    final monthNum = widget.selectedDate.month.toString().padLeft(2, '0');
    final monthAbbr = DateFormat('MMM').format(widget.selectedDate).toUpperCase();

    final localTimeStr = DateFormat('h:mm a').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Giant Editorial Date (matching Image 1 Left)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekdayStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$dayNum.$monthNum',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.8,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        monthAbbr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Full date line for clarity & test compatibility
                  Text(
                    monthDayFullStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.secondaryLightText.withOpacity(0.8) : AppColors.secondaryDarkText.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Right: Local System Clock Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildClockCard(
                  title: _locationName,
                  time: localTimeStr,
                  isDark: isDark,
                  isLocal: true,
                ),
                if (!isToday) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: widget.onReturnToToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : AppColors.pillBlack,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.today_rounded,
                            size: 14,
                            color: isDark ? AppColors.pillBlack : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.pillBlack : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClockCard({
    required String title,
    required String time,
    required bool isDark,
    bool isLocal = true,
  }) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.warmAmber.withOpacity(0.4) : AppColors.warmAmber,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warmAmber,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
