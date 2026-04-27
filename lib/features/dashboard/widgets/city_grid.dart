// Update bagian itemBuilder di CityGrid:

itemBuilder: (context, index) {
  final building = provider.slots[index];
  
  return GestureDetector(
    onTap: () => _showBuildMenu(context, index), // Fungsi buat milih gedung
    child: Container(
      decoration: BoxDecoration(
        color: building == null ? AppColors.cardBg : AppColors.primaryNeon.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: building == null ? Colors.white10 : AppColors.primaryNeon
        ),
      ),
      child: building == null 
        ? Icon(Icons.add, color: Colors.white24) 
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(building.assetPath, height: 40), // Pake aset gedung lu
              Text(building.name, style: TextStyle(fontSize: 8, color: Colors.white)),
            ],
          ),
    ),
  );
}
