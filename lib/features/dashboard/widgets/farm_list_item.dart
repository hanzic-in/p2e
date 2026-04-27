import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatelessWidget {
  final FarmItem item;
  final VoidCallback onTap;
  final VoidCallback onUpgrade;
  final VoidCallback onSell;

  const FarmListItem({
    required this.item, 
    required this.onTap, 
    required this.onUpgrade, 
    required this.onSell
  });

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
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 50, width: 50,
                child: item.status == ProductionStatus.locked 
                  ? const Icon(Icons.lock, color: Colors.white24)
                  : Image.asset(item.assetPath, errorBuilder: (c, e, s) => const Icon(Icons.grass, color: Colors.white10)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item.name} (Lv.${item.level})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(item.status == ProductionStatus.producing 
                      ? "Proses: ${item.remainingSeconds}s" 
                      : "Gudang: ${item.stock} item", 
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: item.status == ProductionStatus.locked ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getBtnColor(),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(_getBtnText()),
              ),
            ],
          ),
          if (item.status != ProductionStatus.locked) ...[
            const Divider(color: Colors.white10, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionIcon(Icons.upgrade, "UPGRADE (${item.upgradePrice.toInt()})", Colors.amber, onUpgrade),
                _actionIcon(Icons.sell, "JUAL", Colors.blueAccent, onSell),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, Color color, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getBorderColor() => item.status == ProductionStatus.ready ? AppColors.primaryGreen : Colors.white10;
  Color _getBtnColor() {
    if (item.status == ProductionStatus.idle) return AppColors.primaryGreen;
    if (item.status == ProductionStatus.ready) return Colors.amber;
    return Colors.white24;
  }
  String _getBtnText() {
    if (item.status == ProductionStatus.idle) return "PANEN";
    if (item.status == ProductionStatus.ready) return "KLAIM";
    if (item.status == ProductionStatus.producing) return "${item.remainingSeconds}s";
    return "LOCKED";
  }
}
