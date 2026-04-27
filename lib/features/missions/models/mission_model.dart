class MissionStep {
  final int order;
  final String title;
  final String description;
  final int reward;
  final String type;
  final String? exampleImageUrl;

  MissionStep({
    required this.order,
    required this.title,
    required this.description,
    required this.reward,
    required this.type,
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
    required this.id,
    required this.title,
    required this.logoUrl,
    required this.bannerUrl,
    required this.totalReward,
    required this.steps,
  });
}
