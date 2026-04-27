import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER LOGO & NAMA
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Icon(Icons.account_balance_wallet_rounded, 
                         color: AppColors.primaryGreen, size: 48),
                    const SizedBox(height: 10),
                    const Text("CITY WALLET", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                    const Text("Aset & Penarikan Saldo", 
                      style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // 2. KARTU SALDO UTAMA
              _buildMainBalanceCard(),

              const SizedBox(height: 30),
              const Text("PILIH METODE PENARIKAN", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 15),

              // 3. OPSI PENARIKAN (DANA, GOPAY, OVO)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wdMethod("DANA", "https://upload.wikimedia.org/wikipedia/commons/7/72/Logo_danain.png"),
                  _wdMethod("GOPAY", "https://upload.wikimedia.org/wikipedia/commons/8/86/Gopay_logo.png"),
                  _wdMethod("OVO", "https://upload.wikimedia.org/wikipedia/commons/e/eb/Logo_ovo_purple.png"),
                ],
              ),

              const SizedBox(height: 30),
              
              // 4. TOMBOL TARIK SALDO
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("TARIK SALDO SEKARANG", 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                ),
              ),

              const SizedBox(height: 10),
              const Center(
                child: Text("Minimum penarikan: 50.000 B-Coins", 
                  style: TextStyle(color: Colors.white24, fontSize: 10)),
              ),

              const SizedBox(height: 30),
              const Text("RIWAYAT TERAKHIR", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 15),

              // 5. LIST RIWAYAT (DUMMY)
              _historyItem("Klaim Gandum #12", "+1.5", "Barusan", true),
              _historyItem("Misi AstraPay", "+5.000", "Kemarin", true),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Column(
        children: [
          const Text("SALDO B-COIN", 
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text("1.250,5", 
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Divider(color: Colors.white10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _subBalance("SPECIAL", "0.0042", AppColors.primaryGreen),
              _subBalance("KEY", "12.0", Colors.amber),
            ],
          )
        ],
      ),
    );
  }

  Widget _subBalance(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  Widget _wdMethod(String label, String url) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Image.network(url, height: 22, errorBuilder: (c, e, s) => const Icon(Icons.payment, color: Colors.white10)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(String title, String amount, String time, bool isPlus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
          Text(amount, style: TextStyle(color: isPlus ? AppColors.primaryGreen : Colors.redAccent, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
