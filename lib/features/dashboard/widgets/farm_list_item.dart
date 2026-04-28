import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/farm_item_model.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatefulWidget {
  final FarmItem item;
  final List<FarmItem> allItems;
  final VoidCallback onTap;
  final VoidCallback onUpgrade;
  final VoidCallback onSell;

  const FarmListItem({
    super.key,
    required this.item, 
    required this.allItems,
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
    bool isLocked = widget.item.status == ProductionStatus.locked;
    bool isWorking = isProducing || widget.item.isUpgrading || widget.item.isUnlocking;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          if (isWorking)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: SweepGradient(
                        colors: [
                          AppColors.cardBg, 
                          widget.item.isUpgrading ? Colors.amber : AppColors.primaryGreen, 
                          AppColors.cardBg
                        ],
                        transform: GradientRotation(_rotationController.value * math.pi * 2),
                      ),
                    ),
                  );
                },
              ),
            ),

          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.item.status == ProductionStatus.ready 
                  ? AppColors.primaryGreen 
                  : (isWorking ? Colors.white24 : Colors.white.withOpacity(0.05)),
                width: widget.item.status == ProductionStatus.ready ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildVisualAset(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name.toUpperCase(), 
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 16, 
                              color: isLocked ? Colors.white24 : Colors.white, 
                              letterSpacing: 1.2
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.isUpgrading 
                              ? "MENINGKATKAN KE LVL ${widget.item.level + 1}..." 
                              : "LEVEL ${widget.item.level} | STOCK: ${widget.item.stock}", 
                            style: TextStyle(
                              color: widget.item.isUpgrading ? Colors.amber : AppColors.textGray, 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildMainButton(),
                  ],
                ),
                
                // Syarat Item (Dependency)
                if (isLocked && widget.item.unlockRequirements.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text("KETERGANTUNGAN", 
                    style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  _buildRequirementIcons(),
                ],

                // Action Buttons (Upgrade & Jual)
                if (!isLocked) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionButton(
                        icon: widget.item.isUpgrading ? Icons.hourglass_top_rounded : Icons.arrow_circle_up_rounded, 
                        label: widget.item.isUpgrading 
                          ? "UPGRADING..." 
                          : "UPGRADE (${widget.item.upgradePrice.toInt()})", 
                        color: widget.item.isUpgrading ? Colors.white24 : Colors.amber, 
                        action: widget.item.isUpgrading ? () {} : widget.onUpgrade,
                      ),
                      _actionButton(
                        icon: Icons.monetization_on_rounded, 
                        label: "JUAL STOK", 
                        color: isWorking ? Colors.white24 : Colors.blueAccent, 
                        action: isWorking ? () {} : widget.onSell,
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

  // --- WIDGET HELPERS ---

  Widget _buildRequirementIcons() {
    return Wrap(
      spacing: 15,
      children: widget.item.unlockRequirements.map((reqName) {
        final reqItem = widget.allItems.firstWhere(
          (f) => f.name == reqName,
          orElse: () => widget.item,
        );
        bool isMet = reqItem.status != ProductionStatus.locked;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isMet ? Colors.white.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isMet ? Colors.white10 : Colors.red.withOpacity(0.2)),
              ),
              child: Opacity(
                opacity: isMet ? 1.0 : 0.3,
                child: Image.asset(reqItem.assetPath, height: 25, width: 25, 
                  errorBuilder: (c, e, s) => const Icon(Icons.help_outline, size: 20, color: Colors.white10)),
              ),
            ),
            const SizedBox(height: 4),
            Text("LVL ${reqItem.level}", 
              style: TextStyle(color: isMet ? Colors.white38 : Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildVisualAset() {
    return Container(
      height: 65, width: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: widget.item.status == ProductionStatus.locked 
        ? const Icon(Icons.lock_outline, color: Colors.white10, size: 28)
        : ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(widget.item.assetPath, fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported_outlined, color: Colors.white10)),
          ),
    );
  }

  Widget _buildMainButton() {
    Color btnColor = Colors.white10;
    String btnText = "LOCKED";
    Color textColor = Colors.white24;
    
    if (widget.item.isUnlocking) {
      btnText = "${widget.item.unlockRemainingSeconds}S";
      btnColor = Colors.white10;
      textColor = AppColors.primaryGreen;
    } else if (widget.item.isUpgrading) {
      btnText = "${widget.item.upgradeRemainingSeconds}S";
      btnColor = Colors.white.withOpacity(0.05);
      textColor = Colors.amber;
    } else {
      switch (widget.item.status) {
        case ProductionStatus.locked:
          btnText = "BUKA (${widget.item.unlockCost.toInt()})"; 
          btnColor = Colors.white.withOpacity(0.08);
          textColor = AppColors.primaryGreen;
          break;
        case ProductionStatus.idle: 
          btnColor = AppColors.primaryGreen; 
          btnText = "MULAI"; 
          textColor = Colors.black;
          break;
        case ProductionStatus.ready: 
          btnColor = Colors.amber; 
          btnText = "KLAIM"; 
          textColor = Colors.black;
          break;
        case ProductionStatus.producing: 
          btnColor = Colors.white.withOpacity(0.05); 
          btnText = "${widget.item.remainingSeconds}S"; 
          textColor = AppColors.primaryGreen;
          break;
      }
    }

    return InkWell(
      onTap: (widget.item.isUpgrading || widget.item.isUnlocking) ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: btnColor, 
          borderRadius: BorderRadius.circular(12),
          border: (widget.item.status == ProductionStatus.locked || widget.item.isUpgrading)
              ? Border.all(color: textColor.withOpacity(0.3)) 
              : null,
        ),
        child: Text(
          btnText,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback action}) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
