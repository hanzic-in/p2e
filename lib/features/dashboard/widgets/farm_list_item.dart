import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/farm_item_model.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatefulWidget {
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
  State<FarmListItem> createState() => _FarmListItemState();
}

class _FarmListItemState extends State<FarmListItem> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), 
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isProducing = widget.item.status == ProductionStatus.producing;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          if (isProducing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: SweepGradient(
                        center: Alignment.center,
                        startAngle: 0.0,
                        endAngle: math.pi * 2,
                        stops: const [0.1, 0.4, 0.6, 0.9],
                        colors: [
                          AppColors.cardBg,
                          Colors.amber.withOpacity(0.8),
                          AppColors.primaryGreen,
                          AppColors.cardBg,
                        ],
                        transform: GradientRotation(_rotationController.value * math.pi * 2),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 2. Konten Utama Card
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.item.status == ProductionStatus.ready 
                  ? AppColors.primaryGreen 
                  : Colors.white.withOpacity(0.05),
                width: widget.item.status == ProductionStatus.ready ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Visual Aset
                    _buildVisualAset(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name.toUpperCase(), 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1.2)
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "LEVEL ${widget.item.level} | STOCK: ${widget.item.stock}", 
                            style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          if (widget.item.status == ProductionStatus.idle && widget.item.level < 5)
                            _buildSaranUpgrade(),
                        ],
                      ),
                    ),
                    // Tombol Utama
                    _buildMainButton(),
                  ],
                ),
                
                if (widget.item.status != ProductionStatus.locked) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionButton(
                        icon: Icons.arrow_circle_up_rounded, 
                        label: "UPGRADE (${widget.item.upgradePrice.toInt()})", 
                        color: Colors.amber, 
                        action: widget.onUpgrade,
                      ),
                      _actionButton(
                        icon: Icons.monetization_on_rounded, 
                        label: "JUAL STOK", 
                        color: Colors.blueAccent, 
                        action: widget.onSell,
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildVisualAset() {
    return Container(
      height: 60, width: 60,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
      child: widget.item.status == ProductionStatus.locked 
        ? const Icon(Icons.lock_outline, color: Colors.white24, size: 28)
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(widget.item.assetPath, fit: BoxFit.contain),
          ),
    );
  }

  Widget _buildSaranUpgrade() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.bolt, color: Colors.amber, size: 10),
          SizedBox(width: 4),
          Text(
            "OPTIMALKAN PRODUKSI", 
            style: TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    Color btnColor = Colors.white24;
    String btnText = "LOCKED";
    
    switch (widget.item.status) {
      case ProductionStatus.idle: btnColor = AppColors.primaryGreen; btnText = "MULAI"; break;
      case ProductionStatus.ready: btnColor = Colors.amber; btnText = "KLAIM"; break;
      case ProductionStatus.producing: btnColor = Colors.white10; btnText = "${widget.item.remainingSeconds}S"; break;
      default: break;
    }

    return InkWell(
      onTap: widget.item.status == ProductionStatus.locked ? null : widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(12)),
        child: Text(
          btnText,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback action}) {
    return InkWell(
      onTap: action,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
