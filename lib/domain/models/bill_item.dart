class BillItem {
  final String id;
  final String name;
  final double amount;
  final String currency; // 'INR', 'GBP', 'USD', 'EUR'
  final String renewalDate; // YYYY-MM-DD
  final String recurrence; // 'monthly', 'yearly', 'weekly'
  final String category;
  final String brandLogo; // 'spotify', 'youtube', 'chatgpt', 'athlytic', 'netflix', 'github', 'generic'
  final String? customImagePath;
  final int reminderDaysBefore;
  final bool isPaused;
  final bool isArchived;
  final DateTime createdAt;

  const BillItem({
    required this.id,
    required this.name,
    required this.amount,
    this.currency = 'INR',
    required this.renewalDate,
    this.recurrence = 'monthly',
    this.category = 'entertainment',
    this.brandLogo = 'generic',
    this.customImagePath,
    this.reminderDaysBefore = 1,
    this.isPaused = false,
    this.isArchived = false,
    required this.createdAt,
  });

  BillItem copyWith({
    String? id,
    String? name,
    double? amount,
    String? currency,
    String? renewalDate,
    String? recurrence,
    String? category,
    String? brandLogo,
    String? customImagePath,
    int? reminderDaysBefore,
    bool? isPaused,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      renewalDate: renewalDate ?? this.renewalDate,
      recurrence: recurrence ?? this.recurrence,
      category: category ?? this.category,
      brandLogo: brandLogo ?? this.brandLogo,
      customImagePath: customImagePath ?? this.customImagePath,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isPaused: isPaused ?? this.isPaused,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool isDueOnDate(DateTime date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (renewalDate == dateStr) return true;

    final parts = renewalDate.split('-');
    if (parts.length >= 3) {
      final dueDay = int.tryParse(parts[2]);
      if (dueDay == null) return false;

      if (recurrence.toLowerCase() == 'monthly') {
        return date.day == dueDay;
      } else if (recurrence.toLowerCase() == 'yearly') {
        final dueMonth = int.tryParse(parts[1]);
        return date.month == dueMonth && date.day == dueDay;
      }
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'renewal_date': renewalDate,
      'recurrence': recurrence,
      'category': category,
      'brand_logo': brandLogo,
      'custom_image_path': customImagePath,
      'reminder_days_before': reminderDaysBefore,
      'is_paused': isPaused ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'INR',
      renewalDate: map['renewal_date'] as String,
      recurrence: map['recurrence'] as String? ?? 'monthly',
      category: map['category'] as String? ?? 'entertainment',
      brandLogo: map['brand_logo'] as String? ?? 'generic',
      customImagePath: map['custom_image_path'] as String?,
      reminderDaysBefore: map['reminder_days_before'] as int? ?? 1,
      isPaused: (map['is_paused'] as int) == 1,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class BillPaymentRecord {
  final String id;
  final String billId;
  final String paidDate; // YYYY-MM-DD
  final double amountPaid;
  final String currency;

  const BillPaymentRecord({
    required this.id,
    required this.billId,
    required this.paidDate,
    required this.amountPaid,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'paid_date': paidDate,
      'amount_paid': amountPaid,
      'currency': currency,
    };
  }

  factory BillPaymentRecord.fromMap(Map<String, dynamic> map) {
    return BillPaymentRecord(
      id: map['id'] as String,
      billId: map['bill_id'] as String,
      paidDate: map['paid_date'] as String,
      amountPaid: (map['amount_paid'] as num).toDouble(),
      currency: map['currency'] as String,
    );
  }
}
