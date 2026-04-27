import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _bannerAds = [
    "https://images.unsplash.com/photo-1611974714112-9e90098f98b9?q=80&w=800",
    "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=800",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _bannerAds.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // --- FUNGSI POPUP (DITARUH DI SINI) ---
  void _showWithdrawPopup(BuildContext context, String provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TARIK KE $provider", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 20),
              const Text("NOMOR AKUN", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Contoh: 08123456789",
                  hintStyle: const TextStyle(color: Colors.white10),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.phone_android, color: Colors.white24),
                ),
              ),
              const SizedBox(height: 25),
              const Text("PILIH NOMINAL", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: [_nominalChip("10.000"), _nominalChip("25.000"), _nominalChip("50.000"), _nominalChip("100.000")],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permintaan penarikan sedang diproses!")));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("KONFIRMASI PENARIKAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nominalChip(String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
      child: Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

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
              _buildHeader(),
              const SizedBox(height: 30),
              _buildMainBalanceCard(),
              const SizedBox(height: 30),
              const Text("PILIH METODE PENARIKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wdMethod("DANA", "https://upload.wikimedia.org/wikipedia/commons/7/72/Logo_danain.png"),
                  _wdMethod("GOPAY", "https://upload.wikimedia.org/wikipedia/commons/8/86/Gopay_logo.png"),
                  _wdMethod("OVO", "https://upload.wikimedia.org/wikipedia/commons/e/eb/Logo_ovo_purple.png"),
                ],
              ),
              const SizedBox(height: 30),
              _buildWdButton(),
              const SizedBox(height: 10),
              const Center(child: Text("Minimum penarikan: 50.000 B-Coins", style: TextStyle(color: Colors.white24, fontSize: 10))),
              const SizedBox(height: 30),
              _buildAdBanner(),
              const SizedBox(height: 20),
              const Text("RIWAYAT TERAKHIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 15),
              _historyItem("Klaim Gandum #12", "+1.5", "Barusan", true),
              _historyItem("Misi AstraPay", "+5.000", "Kemarin", true),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _wdMethod(String label, String url) {
    return InkWell(
      onTap: () => _showWithdrawPopup(context, label),
      child: Container(
        width: 100, padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.05))),
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

  Widget _buildAdBanner() {
    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _bannerAds.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: AppColors.cardBg, borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: NetworkImage(_bannerAds[index]), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken)),
            ),
            child: Stack(children: [Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: const Text("AD", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))))]),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Center(child: Column(children: [const SizedBox(height: 10), Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryGreen, size: 48), const SizedBox(height: 10), const Text("CITY WALLET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)), const Text("Aset & Penarikan Saldo", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold))]));
  }

  Widget _buildMainBalanceCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: [const Text("SALDO B-COIN", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 8), const Text("1.250,5", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)), const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Divider(color: Colors.white10)), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_subBalance("SPECIAL", "0.0042", AppColors.primaryGreen), _subBalance("KEY", "12.0", Colors.amber)])]),
    );
  }

  Widget _buildWdButton() {
    return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0), child: const Text("TARIK SALDO SEKARANG", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1))));
  }

  Widget _subBalance(String label, String value, Color color) {
    return Column(children: [Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16))]);
  }

  Widget _historyItem(String title, String amount, String time, bool isPlus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10))]), Text(amount, style: TextStyle(color: isPlus ? AppColors.primaryGreen : Colors.redAccent, fontWeight: FontWeight.w900))]),
    );
  }
}
