import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/bill_item.dart';

class BillsModule extends StatelessWidget {
  final List<BillItem> bills;
  final Map<String, double> currencyTotals;
  final Function(String, double, String) onMarkPaid;
  final Function(String) onDeleteBill;
  final VoidCallback onAddBill;

  const BillsModule({
    super.key,
    required this.bills,
    required this.currencyTotals,
    required this.onMarkPaid,
    required this.onDeleteBill,
    required this.onAddBill,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spend Summary Card (Totals separated by currency as required in prompt)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Spend Totals',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                      ),
                    ),
                    IconButton(
                      onPressed: onAddBill,
                      icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.warmAmber),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (currencyTotals.isEmpty)
                  const Text('No active subscriptions or bills.', style: TextStyle(fontSize: 16))
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: currencyTotals.entries.map((entry) {
                      final symbol = _getSymbol(entry.key);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Text(
                            '$symbol${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Subscriptions List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscriptions & Bills (${bills.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: onAddBill,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Bill'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (bills.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.payment_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('No subscriptions tracked yet.', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Keep track of renewal dates and payments offline.'),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bills.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final bill = bills[index];
                return _buildBillCard(context, bill, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, BillItem bill, bool isDark) {
    final symbol = _getSymbol(bill.currency);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          // Brand Icon or Custom Image
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getBrandColor(bill.brandLogo),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: (bill.customImagePath != null && File(bill.customImagePath!).existsSync())
                ? Image.file(File(bill.customImagePath!), width: 44, height: 44, fit: BoxFit.cover)
                : Icon(_getBrandIcon(bill.brandLogo), color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          // Name and renewal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Renews: ${bill.renewalDate} • ${bill.recurrence}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
              ],
            ),
          ),

          // Amount & Mark Paid Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$symbol${bill.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => onMarkPaid(bill.id, bill.amount, bill.currency),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.sageForeground),
                      SizedBox(width: 4),
                      Text(
                        'Mark Paid',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.sageForeground),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Delete icon
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
            onPressed: () => onDeleteBill(bill.id),
          ),
        ],
      ),
    );
  }

  String _getSymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'INR':
      default:
        return '₹';
    }
  }

  Color _getBrandColor(String logo) {
    switch (logo.toLowerCase()) {
      case 'gpay':
      case 'googlepay':
        return const Color(0xFF4285F4);
      case 'phonepe':
        return const Color(0xFF5F259F);
      case 'paytm':
        return const Color(0xFF002970);
      case 'amazonpay':
        return const Color(0xFFFF9900);
      case 'paypal':
        return const Color(0xFF003087);
      case 'applepay':
        return Colors.black87;
      case 'bank':
        return const Color(0xFF2C5E8A);
      case 'cash':
        return const Color(0xFF2E7D32);
      case 'spotify':
        return const Color(0xFF1DB954);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'chatgpt':
        return Colors.black;
      case 'athlytic':
        return const Color(0xFF8A2BE2);
      case 'netflix':
        return const Color(0xFFE50914);
      default:
        return AppColors.warmAmber;
    }
  }

  IconData _getBrandIcon(String logo) {
    switch (logo.toLowerCase()) {
      case 'gpay':
      case 'googlepay':
        return Icons.account_balance_wallet_rounded;
      case 'phonepe':
        return Icons.currency_rupee_rounded;
      case 'paytm':
        return Icons.payment_rounded;
      case 'amazonpay':
        return Icons.shopping_bag_rounded;
      case 'paypal':
        return Icons.credit_card_rounded;
      case 'applepay':
        return Icons.apple_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'spotify':
        return Icons.music_note_rounded;
      case 'youtube':
        return Icons.play_arrow_rounded;
      case 'chatgpt':
        return Icons.auto_awesome;
      case 'athlytic':
        return Icons.fitness_center_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
