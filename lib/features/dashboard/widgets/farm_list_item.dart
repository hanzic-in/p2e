import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatelessWidget {
  final FarmItem item;
  final VoidCallback onTap;
  final VoidCallback onUpgrade;
  final VoidCallback onSell;

  const FarmListItem({
    super.key,
    required this.item, 
    required this.onTap, 
    required this.onUpgrade, 
    required this.onSell
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.status == ProductionStatus.ready 
            ? AppColors.primaryGreen 
            : Colors.white.withOpacity(0.05),
          width: item.status == ProductionStatus.ready ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Visual Aset
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: item.status == ProductionStatus.locked 
                  ? const Icon(Icons.lock_outline, color: Colors.white24, size: 28)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item.assetPath, 
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image_outlined, color: Colors.white10),
                      ),
                    ),
              ),
              const SizedBox(width: 16),
              // Info Item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(), 
                      style: const TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 16, 
                        color: Colors.white,
                        letterSpacing: 1.2
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "LEVEL ${item.level} | STOCK: ${item.stock}", 
                      style: const TextStyle(
                        color: AppColors.textGray, 
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Utama
              _buildMainButton(),
            ],
          ),
          
          if (item.status != ProductionStatus.locked) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.white10, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  icon: Icons.unfold_more_rounded, 
                  label: "UPGRADE (${item.upgradePrice.toInt()})", 
                  color: Colors.amber, 
                  action: onUpgrade,
                  showSaran: true,
                ),
                _actionButton(
                  icon: Icons.account_balance_wallet_outlined, 
                  label: "JUAL ITEM", 
                  color: Colors.blueAccent, 
                  action: onSell,
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return InkWell(
      onTap: item.status == ProductionStatus.locked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _getBtnColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (item.status == ProductionStatus.ready)
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Text(
          _getBtnText(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback action,
    bool showSaran = false,
  }) {
    return InkWell(
      onTap: action,
      child: Column(
        children: [
          if (showSaran) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "OPTIMALKAN PRODUKSI", 
                style: TextStyle(
                  color: Colors.amber, 
                  fontSize: 8, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8
                )
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label, 
                style: TextStyle(
                  color: color, 
                  fontSize: 11, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBtnColor() {
    if (item.status == ProductionStatus.idle) return AppColors.primaryGreen;
    if (item.status == ProductionStatus.ready) return Colors.amber;
    if (item.status == ProductionStatus.producing) return Colors.white10;
    return Colors.white24;
  }

  String _getBtnText() {
    if (item.status == ProductionStatus.idle) return "MULAI";
    if (item.status == ProductionStatus.ready) return "KLAIM";
    if (item.status == ProductionStatus.producing) return "${item.remainingSeconds}S";
    return "LOCKED";
  }
}
