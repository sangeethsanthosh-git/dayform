import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/category_definitions.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/bill_item.dart';
import '../../domain/models/birthday_item.dart';
import '../../domain/models/event_item.dart';
import '../../domain/models/habit_item.dart';
import '../../domain/models/task_item.dart';
import 'parser/natural_language_parser.dart';

class QuickAddSheet extends StatefulWidget {
  final AppState appState;
  final int initialTabIndex;
  final DateTime? initialDate;

  const QuickAddSheet({
    super.key,
    required this.appState,
    this.initialTabIndex = 0,
    this.initialDate,
  });

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _naturalInputController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _durationMinutes = 60;
  String _selectedCategory = 'personal';
  bool _isAllDay = false;
  int _reminderOffset = 15;

  // Bill specific
  String _selectedCurrency = 'INR';
  String _selectedBrandLogo = 'gpay';
  String? _customBillImagePath;

  // Birthday specific
  int _avatarPresetIndex = 0;
  String? _customBirthdayImagePath;
  int? _birthYear;

  // Natural Language Parsed Banner
  ParsedQuickEntry? _parsedEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTabIndex);
    _selectedDate = widget.initialDate ?? widget.appState.selectedDate;
    _selectedCurrency = widget.appState.settings.currency;
    _durationMinutes = widget.appState.settings.defaultEventDurationMinutes;
    _reminderOffset = widget.appState.settings.defaultReminderMinutesBefore;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _naturalInputController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _applyNaturalLanguageParse(String text) {
    if (text.trim().isEmpty) return;
    final parsed = NaturalLanguageParser.parse(text);
    setState(() {
      _parsedEntry = parsed;
      _titleController.text = parsed.title;
      _selectedDate = parsed.date;
      _selectedCategory = parsed.category;
      if (parsed.timeString != null) {
        final parts = parsed.timeString!.split(':');
        _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        _isAllDay = false;
      }
      if (parsed.detectedType == 'event') {
        _tabController.animateTo(0);
      } else if (parsed.detectedType == 'task') {
        _tabController.animateTo(1);
      }
    });
  }

  void _applyTemplate(String templateKey) {
    setState(() {
      switch (templateKey) {
        case 'lecture':
          _titleController.text = 'Class Lecture';
          _selectedCategory = 'study';
          _durationMinutes = 60;
          _reminderOffset = 15;
          _tabController.animateTo(0);
          break;
        case 'assignment':
          _titleController.text = 'Assignment Deadline';
          _selectedCategory = 'study';
          _durationMinutes = 120;
          _reminderOffset = 60;
          _tabController.animateTo(1);
          break;
        case 'workout':
          _titleController.text = 'Strength & Conditioning Workout';
          _selectedCategory = 'health';
          _durationMinutes = 45;
          _reminderOffset = 15;
          _tabController.animateTo(0);
          break;
        case 'subscription':
          _titleController.text = 'Streaming Subscription Renewal';
          _selectedCategory = 'finance';
          _amountController.text = '19.99';
          _tabController.animateTo(3);
          break;
      }
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    const uuid = Uuid();
    final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final startDt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final endDt = startDt.add(Duration(minutes: _durationMinutes));

    switch (_tabController.index) {
      case 0: // Event
        final event = EventItem(
          id: uuid.v4(),
          title: title,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          startDateTime: startDt,
          endDateTime: endDt,
          isAllDay: _isAllDay,
          dateOnly: dateStr,
          category: _selectedCategory,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          reminderMinutesBefore: _reminderOffset > 0 ? _reminderOffset : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await widget.appState.addEvent(event);
        break;

      case 1: // Task
        final task = TaskItem(
          id: uuid.v4(),
          title: title,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          dueDate: dateStr,
          dueTime: "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
          priority: 2, // Medium default
          category: _selectedCategory,
          estimatedDurationMinutes: _durationMinutes,
          reminderMinutesBefore: _reminderOffset,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await widget.appState.addTask(task);
        break;

      case 2: // Reminder
        final reminderEvent = EventItem(
          id: uuid.v4(),
          title: 'Reminder: $title',
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          startDateTime: startDt,
          endDateTime: startDt.add(const Duration(minutes: 15)),
          isAllDay: false,
          dateOnly: dateStr,
          category: 'personal',
          reminderMinutesBefore: 0, // at time
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await widget.appState.addEvent(reminderEvent);
        break;

      case 3: // Bill
        final amount = double.tryParse(_amountController.text.trim()) ?? 10.0;
        final bill = BillItem(
          id: uuid.v4(),
          name: title,
          amount: amount,
          currency: _selectedCurrency,
          renewalDate: dateStr,
          recurrence: 'monthly',
          category: _selectedCategory,
          brandLogo: _selectedBrandLogo,
          customImagePath: _customBillImagePath,
          createdAt: DateTime.now(),
        );
        await widget.appState.addBill(bill);
        break;

      case 4: // Birthday
        final bday = BirthdayItem(
          id: uuid.v4(),
          personName: title,
          birthDate: dateStr,
          birthYear: _birthYear,
          relationship: 'friend',
          avatarPresetIndex: _avatarPresetIndex,
          customImagePath: _customBirthdayImagePath,
          giftIdeas: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: DateTime.now(),
        );
        await widget.appState.addBirthday(bday);
        break;

      case 5: // Habit
        final habit = HabitItem(
          id: uuid.v4(),
          title: title,
          category: _selectedCategory,
          scheduledDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
          createdAt: DateTime.now(),
        );
        await widget.appState.addHabit(habit);
        break;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "$title" to Dayform!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title & Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick Add', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.bookmark_border_rounded),
                tooltip: 'Templates',
                onSelected: _applyTemplate,
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'lecture', child: Text('Class Lecture')),
                  const PopupMenuItem(value: 'assignment', child: Text('Assignment Deadline')),
                  const PopupMenuItem(value: 'workout', child: Text('Workout Session')),
                  const PopupMenuItem(value: 'subscription', child: Text('Subscription Renewal')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Offline Natural Language Input Field
          TextField(
            controller: _naturalInputController,
            decoration: InputDecoration(
              hintText: 'e.g. Submit assignment tomorrow at 6 pm',
              prefixIcon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.warmAmber),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                onPressed: () => _applyNaturalLanguageParse(_naturalInputController.text),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: _applyNaturalLanguageParse,
          ),
          if (_parsedEntry != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sage.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sage),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.sageForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Interpreted: ${_parsedEntry!.title} (${DateFormat('d MMM').format(_parsedEntry!.date)}${_parsedEntry!.timeString != null ? " at ${_parsedEntry!.timeString}" : ""})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.sageForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Type Selector Tabs (Event, Task, Reminder, Bill, Birthday, Habit)
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.warmAmberForeground,
            indicatorColor: AppColors.warmAmber,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Event'),
              Tab(text: 'Task'),
              Tab(text: 'Reminder'),
              Tab(text: 'Bill'),
              Tab(text: 'Birthday'),
              Tab(text: 'Habit'),
            ],
          ),
          const SizedBox(height: 14),

          // Form fields (Scrollable)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'What are you planning?',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date & Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(DateFormat('d MMM yyyy').format(_selectedDate)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!_isAllDay)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (picked != null) setState(() => _selectedTime = picked);
                            },
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(_selectedTime.format(context)),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Selector
                  Row(
                    children: [
                      const Text('Category: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: CategoryDefinitions.all.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(c.icon, size: 16, color: c.foregroundColor),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Specific fields for Bill (tab 3) and Birthday (tab 4)
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      if (_tabController.index == 3) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Amount (e.g. 19.99)'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCurrency,
                                    decoration: const InputDecoration(labelText: 'Currency'),
                                    items: ['INR', 'GBP', 'USD', 'EUR'].map((c) {
                                      return DropdownMenuItem(value: c, child: Text(c));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCurrency = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Payment App / Logo Preset',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  'gpay',
                                  'phonepe',
                                  'paytm',
                                  'amazonpay',
                                  'paypal',
                                  'applepay',
                                  'bank',
                                  'cash',
                                  'spotify',
                                  'netflix',
                                ].map((app) {
                                  final isSel = _selectedBrandLogo == app && _customBillImagePath == null;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(app.toUpperCase()),
                                      selected: isSel,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedBrandLogo = app;
                                            _customBillImagePath = null;
                                          });
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Custom Image / Receipt for Payment
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final res = await FilePicker.pickFiles(type: FileType.image);
                                    if (res.isNotEmpty && res.first.path != null) {
                                      setState(() {
                                        _customBillImagePath = res.first.path;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                                  label: const Text('Add Payment App Image / Receipt'),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                if (_customBillImagePath != null) ...[
                                  const SizedBox(width: 10),
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(_customBillImagePath!),
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _customBillImagePath = null),
                                          child: const CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Colors.red,
                                            child: Icon(Icons.close, size: 10, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }

                      if (_tabController.index == 4) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Avatar Preset Style',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(5, (idx) {
                                final isSel = _avatarPresetIndex == idx && _customBirthdayImagePath == null;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _avatarPresetIndex = idx;
                                    _customBirthdayImagePath = null;
                                  }),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSel ? AppColors.warmAmber : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.warmAmber.withOpacity(0.35),
                                      child: Text(
                                        '${idx + 1}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warmAmberForeground),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 10),

                            // Custom Photo for Person
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final res = await FilePicker.pickFiles(type: FileType.image);
                                    if (res.isNotEmpty && res.first.path != null) {
                                      setState(() {
                                        _customBirthdayImagePath = res.first.path;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.person_pin_circle_outlined, size: 16),
                                  label: const Text("Add Person's Photo"),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                if (_customBirthdayImagePath != null) ...[
                                  const SizedBox(width: 12),
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          File(_customBirthdayImagePath!),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _customBirthdayImagePath = null),
                                          child: const CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Colors.red,
                                            child: Icon(Icons.close, size: 10, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  // Notes / Description
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Details (Optional)',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.warmAmber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Add to Schedule', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
