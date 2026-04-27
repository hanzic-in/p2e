class Building {
  final String name;
  final String assetPath;
  final double addedHashrate;
  final int adRequired;

  Building({
    required this.name,
    required this.assetPath,
    required this.addedHashrate,
    required this.adRequired,
  });
}

// Daftar gedung awal
List<Building> buildingList = [
  Building(name: "Small Solar Panel", assetPath: "assets/solar.png", addedHashrate: 0.0005, adRequired: 3),
  Building(name: "Wind Turbine", assetPath: "assets/wind.png", addedHashrate: 0.0015, adRequired: 7),
  Building(name: "Data Center", assetPath: "assets/server.png", addedHashrate: 0.0050, adRequired: 15),
];
