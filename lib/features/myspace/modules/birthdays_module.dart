import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/birthday_item.dart';

class BirthdaysModule extends StatelessWidget {
  final List<BirthdayItem> birthdays;
  final Function(String) onDeleteBirthday;
  final VoidCallback onAddBirthday;

  const BirthdaysModule({
    super.key,
    required this.birthdays,
    required this.onDeleteBirthday,
    required this.onAddBirthday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentYear = DateTime.now().year;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Birthdays & Milestones (${birthdays.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: onAddBirthday,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Birthday'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (birthdays.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.cake_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('No birthdays saved yet.', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Track birthdays, anniversaries, and gift ideas offline.'),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: birthdays.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final bday = birthdays[index];
                final turningAge = bday.getAgeTurning(currentYear);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      // Avatar Sticker (matching reference media_1788962478438.jpg)
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.warmAmber.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.warmAmber, width: 1.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (bday.customImagePath != null && File(bday.customImagePath!).existsSync())
                            ? Image.file(File(bday.customImagePath!), width: 44, height: 44, fit: BoxFit.cover)
                            : Text(
                                bday.personName.isNotEmpty ? bday.personName[0].toUpperCase() : 'B',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warmAmberForeground,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Name, relationship & turning age
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bday.personName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              turningAge != null
                                  ? 'Turns $turningAge • ${bday.relationship}'
                                  : bday.relationship,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                              ),
                            ),
                            if (bday.giftIdeas != null && bday.giftIdeas!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.card_giftcard_rounded, size: 13, color: AppColors.dustyRose),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      bday.giftIdeas!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Date Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bday.birthDate,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                        onPressed: () => onDeleteBirthday(bday.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
