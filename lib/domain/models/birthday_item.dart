class BirthdayItem {
  final String id;
  final String personName;
  final String birthDate; // YYYY-MM-DD or MM-DD
  final int? birthYear;
  final String relationship; // 'friend', 'family', 'partner', 'colleague'
  final int avatarPresetIndex; // 0..7
  final String? customImagePath;
  final String? giftIdeas;
  final String? notes;
  final int reminderDaysBefore;
  final DateTime createdAt;

  const BirthdayItem({
    required this.id,
    required this.personName,
    required this.birthDate,
    this.birthYear,
    this.relationship = 'friend',
    this.avatarPresetIndex = 0,
    this.customImagePath,
    this.giftIdeas,
    this.notes,
    this.reminderDaysBefore = 1,
    required this.createdAt,
  });

  // Calculate milestone age if birthYear is known
  int? getAgeTurning(int referenceYear) {
    if (birthYear == null) return null;
    return referenceYear - birthYear!;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'birth_date': birthDate,
      'birth_year': birthYear,
      'relationship': relationship,
      'avatar_preset_index': avatarPresetIndex,
      'custom_image_path': customImagePath,
      'gift_ideas': giftIdeas,
      'notes': notes,
      'reminder_days_before': reminderDaysBefore,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BirthdayItem.fromMap(Map<String, dynamic> map) {
    return BirthdayItem(
      id: map['id'] as String,
      personName: map['person_name'] as String,
      birthDate: map['birth_date'] as String,
      birthYear: map['birth_year'] as int?,
      relationship: map['relationship'] as String? ?? 'friend',
      avatarPresetIndex: map['avatar_preset_index'] as int? ?? 0,
      customImagePath: map['custom_image_path'] as String?,
      giftIdeas: map['gift_ideas'] as String?,
      notes: map['notes'] as String?,
      reminderDaysBefore: map['reminder_days_before'] as int? ?? 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  BirthdayItem copyWith({
    String? id,
    String? personName,
    String? birthDate,
    int? birthYear,
    String? relationship,
    int? avatarPresetIndex,
    String? customImagePath,
    String? giftIdeas,
    String? notes,
    int? reminderDaysBefore,
    DateTime? createdAt,
  }) {
    return BirthdayItem(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      birthDate: birthDate ?? this.birthDate,
      birthYear: birthYear ?? this.birthYear,
      relationship: relationship ?? this.relationship,
      avatarPresetIndex: avatarPresetIndex ?? this.avatarPresetIndex,
      customImagePath: customImagePath ?? this.customImagePath,
      giftIdeas: giftIdeas ?? this.giftIdeas,
      notes: notes ?? this.notes,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
