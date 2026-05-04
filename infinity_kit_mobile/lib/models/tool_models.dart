class Tool {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String categoryId;
  final bool isNative; // To distinguish between native and web tools
  bool isFavorite;

  Tool({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.categoryId,
    this.isNative = false,
    this.isFavorite = false,
  });
}

class ToolCategory {
  final String id;
  final String name;
  final String emoji;
  final List<String> toolIds;

  ToolCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.toolIds,
  });
}
