import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tool_models.dart';
import '../services/tool_data_service.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';

class CategoryDetailScreen extends StatefulWidget {
  final ToolCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final tools = ToolDataService.getToolsForCategory(widget.category.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return _buildToolCard(context, tool);
          },
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, Tool tool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            tool.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tool.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            if (tool.isFavorite)
              const Icon(Icons.star, color: Colors.amber, size: 20),
          ],
        ),
        subtitle: Text(
          tool.description,
          style: const TextStyle(color: AppTheme.subtitleColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
        onLongPress: () async {
          HapticFeedback.mediumImpact();
          await ToolDataService.toggleFavorite(tool.id);
          setState(() {}); // Refresh UI
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tool.isFavorite ? 'Added to Favorites' : 'Removed from Favorites'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onTap: () async {
          HapticFeedback.lightImpact();
          await ToolDataService.addToRecent(tool.id);
          if (!context.mounted) return;
          ToolNavigation.navigateToTool(context, tool);
        },
      ),
    );
  }
}
