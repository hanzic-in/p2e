import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatelessWidget {
  final FarmItem item;
  final VoidCallback onTap;

  const FarmListItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
      
          Container(
            height: 60, width: 60,
            child: item.status == ProductionStatus.locked 
              ? const Icon(Icons.lock, color: Colors.white24)
              : Image.asset(item.assetPath, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white10)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(item.status == ProductionStatus.producing 
                  ? "Sisa waktu: ${item.remainingSeconds}s" 
                  : "Hasil: ${item.incomeBCoin} B-Coin", 
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
  
          ElevatedButton(
            onPressed: item.status == ProductionStatus.locked ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBtnColor(),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_getBtnText()),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (item.status == ProductionStatus.ready) return AppColors.primaryGreen;
    if (item.status == ProductionStatus.producing) return Colors.amber;
    return Colors.white10;
  }

  Color _getBtnColor() {
    switch (item.status) {
      case ProductionStatus.idle: return AppColors.primaryGreen;
      case ProductionStatus.ready: return Colors.amber;
      case ProductionStatus.producing: return Colors.white24;
      default: return Colors.grey;
    }
  }

  String _getBtnText() {
    switch (item.status) {
      case ProductionStatus.idle: return "PRODUKSI";
      case ProductionStatus.ready: return "KLAIM";
      case ProductionStatus.producing: return "PROSES...";
      default: return "LOCKED";
    }
  }
}
