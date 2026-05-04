import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tool_data_service.dart';
import '../models/tool_models.dart';
import '../utils/theme.dart';
import 'category_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INFINITY KIT'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Recent'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildFavoritesContent();
      case 2:
        return _buildRecentContent();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent() {
    final favorites = ToolDataService.tools.where((t) => t.isFavorite).toList();

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('No favorites yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Long press a tool to add it here!', style: TextStyle(color: AppTheme.subtitleColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final tool = favorites[index];
        return _buildPersistentToolCard(tool);
      },
    );
  }

  Widget _buildRecentContent() {
    final recentTools = ToolDataService.getRecentTools();

    if (recentTools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('No recent activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Your used tools will appear here.', style: TextStyle(color: AppTheme.subtitleColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentTools.length,
      itemBuilder: (context, index) {
        final tool = recentTools[index];
        return _buildPersistentToolCard(tool);
      },
    );
  }

  Widget _buildPersistentToolCard(Tool tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Text(tool.icon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(tool.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
        onTap: () async {
          HapticFeedback.lightImpact();
          await ToolDataService.addToRecent(tool.id);
          if (mounted) {
             // Find category to navigate or just navigate to tool
             final category = ToolDataService.categories.firstWhere((c) => c.id == tool.categoryId);
             Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(category: category)));
             // Actually, we should navigate directly to the tool. 
             // But the logic is in CategoryDetailScreen. 
             // We can refactor navigation later. For now, this works.
          }
        },
      ),
    );
  }



  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search tools...',
          prefixIcon: Icon(Icons.search, color: AppTheme.subtitleColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = ToolDataService.categories;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(ToolCategory category) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.toolIds.length} Tools',
              style: const TextStyle(
                color: AppTheme.subtitleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
