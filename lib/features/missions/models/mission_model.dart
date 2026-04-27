class MissionStep {
  final int order;
  final String title;
  final String description;
  final int reward;
  final String type;
  final String? exampleImageUrl;

  MissionStep({
    this.order = 1,
    this.title = "", 
    this.description = "", 
    this.reward = 0, 
    this.type = "info",
    this.exampleImageUrl,
  });
}

class Mission {
  final String id;
  final String title;
  final String logoUrl;
  final String bannerUrl;
  final int totalReward;
  final List<MissionStep> steps;

  Mission({
    this.id = "0",
    required this.title,
    required this.logoUrl,
    required this.bannerUrl,
    required this.totalReward,
    this.steps = const [],
  });
}
