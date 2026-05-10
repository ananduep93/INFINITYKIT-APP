import 'package:shared_preferences/shared_preferences.dart';
import '../models/tool_models.dart';
import 'firestore_service.dart';

class ToolDataService {
  static late SharedPreferences _prefs;
  static final FirestoreService _firestore = FirestoreService();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
  }

  static void _loadFavorites() {
    final favoriteIds = _prefs.getStringList('favorite_tool_ids') ?? [];
    for (var tool in tools) {
      if (favoriteIds.contains(tool.id)) {
        tool.isFavorite = true;
      }
    }
  }

  static Future<void> toggleFavorite(String toolId) async {
    final tool = tools.firstWhere((t) => t.id == toolId);
    tool.isFavorite = !tool.isFavorite;
    
    final favoriteIds = tools.where((t) => t.isFavorite).map((t) => t.id).toList();
    await _prefs.setStringList('favorite_tool_ids', favoriteIds);
    
    // Sync to centralized settings (fire and forget for smoothness)
    _syncSettingsToCloud();
  }

  static Future<void> addToRecent(String toolId) async {
    List<String> recentIds = _prefs.getStringList('recent_tool_ids') ?? [];
    recentIds.remove(toolId);
    recentIds.insert(0, toolId);
    if (recentIds.length > 20) recentIds = recentIds.sublist(0, 20);
    await _prefs.setStringList('recent_tool_ids', recentIds);
    
    // Sync to centralized settings (fire and forget for smoothness)
    _syncSettingsToCloud();
  }

  static Future<void> _syncSettingsToCloud() async {
    final favorites = _prefs.getStringList('favorite_tool_ids') ?? [];
    final recent = _prefs.getStringList('recent_tool_ids') ?? [];
    
    await _firestore.saveSettings({
      'favorites': favorites,
      'recentTools': recent,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> syncSettingsFromCloud() async {
    final settings = await _firestore.getSettings();
    if (settings == null) return;

    if (settings['favorites'] is List) {
      final List<String> favorites = List<String>.from(settings['favorites']);
      await _prefs.setStringList('favorite_tool_ids', favorites);
      for (var tool in tools) {
        tool.isFavorite = favorites.contains(tool.id);
      }
    }

    if (settings['recentTools'] is List) {
      final List<String> recent = List<String>.from(settings['recentTools']);
      await _prefs.setStringList('recent_tool_ids', recent);
    }
  }

  static List<Tool> getRecentTools() {
    final recentIds = _prefs.getStringList('recent_tool_ids') ?? [];
    return recentIds
        .map((id) => tools.firstWhere((t) => t.id == id, orElse: () => Tool(id: '', name: '', icon: '', description: '', categoryId: '')))
        .where((t) => t.id.isNotEmpty)
        .toList();
  }

  static final List<ToolCategory> categories = [
    ToolCategory(id: 'daily-essentials', name: 'Daily Essentials', emoji: '🏠', toolIds: ['todolist', 'notes', 'timer']),
    ToolCategory(id: 'expense-tracker', name: 'Expense Tracker', emoji: '💸', toolIds: ['expenseadd', 'expenselist', 'categorysummary', 'report', 'budget', 'search-expense', 'reset-data', 'analytics', 'spending-insights', 'suggestions']),
    ToolCategory(id: 'survey-hub', name: 'Survey Hub', emoji: '📈', toolIds: ['surveybuilder', 'mysurveys', 'publicsurvey']),
    ToolCategory(id: 'utilities', name: 'Utilities', emoji: '🛠️', toolIds: ['unitconverter', 'passwordgen', 'passwordsaver', 'passwordstrength', 'randomnamepicker', 'usernamegen', 'clipboardcleaner']),
    ToolCategory(id: 'pdf-tools', name: 'PDF Tools', emoji: '📄', toolIds: ['imagetopdf', 'pdftoimage', 'mergepdf', 'rotatepdf']),
    ToolCategory(id: 'image-tools', name: 'Image Tools', emoji: '🖼️', toolIds: ['compressimage', 'imageinfo']),
    ToolCategory(id: 'math-tools', name: 'Math Tools', emoji: '➗', toolIds: ['discountcalc', 'percentagecalc', 'primenumber', 'palindrome', 'factorial', 'fibonacci', 'lcmhcf', 'trianglechecker', 'distancecalc', 'equationsolver']),
    ToolCategory(id: 'time-tools', name: 'Time Tools', emoji: '📅', toolIds: ['daysbetween']),
    ToolCategory(id: 'student-tools', name: 'Student Tools', emoji: '🎓', toolIds: ['examcalc']),
    ToolCategory(id: 'quick-tools', name: 'Quick Tools', emoji: '⚡', toolIds: ['texttospeech', 'wordcounter', 'textreverse', 'caseconverter', 'removeduplicates']),
    ToolCategory(id: 'data-tools', name: 'Data Tools', emoji: '📊', toolIds: ['graphmaker', 'averagecalculator', 'numbersorter', 'csvviewer']),
    ToolCategory(id: 'decision-tools', name: 'Decision Tools', emoji: '🎯', toolIds: ['spinwheel', 'yesnogerator', 'choicecomparator']),
    ToolCategory(id: 'planner-tools', name: 'Planner Tools', emoji: '🗓️', toolIds: ['calendarviewer', 'dailyplanner', 'reminderalert']),
    ToolCategory(id: 'web-tools', name: 'Web Tools', emoji: '🌐', toolIds: ['urlencoder', 'urlextractor', 'metatagviewer']),
    ToolCategory(id: 'health-utility-hub', name: 'Health Utility Hub', emoji: '🏥', toolIds: ['bmicalculator', 'drugdosage', 'ivdripcalc', 'medicinereminder']),
    ToolCategory(id: 'ai-tools', name: 'AI Tools', emoji: '🤖', toolIds: ['chatbot', 'text-improver', 'summarizer', 'image-generator', 'codehelper', 'translator', 'voiceassistant', 'docchecker']),
  ];

  static final List<Tool> tools = [
    // Daily Essentials
    Tool(id: 'todolist', name: 'To-Do List', icon: '✓', description: 'Manage your tasks', categoryId: 'daily-essentials', isNative: true),
    Tool(id: 'notes', name: 'Quick Notes', icon: '📝', description: 'Take quick notes', categoryId: 'daily-essentials', isNative: true),
    Tool(id: 'timer', name: 'Timer & Stopwatch', icon: '⏱️', description: 'Track time', categoryId: 'daily-essentials', isNative: true),
    
    // Expense Tracker
    Tool(id: 'expenseadd', name: 'Add Expense', icon: '➕💸', description: 'Add a new expense', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'expenselist', name: 'Expense List', icon: '📋', description: 'View and manage expenses', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'categorysummary', name: 'Category Summary', icon: '📊', description: 'Expenses by category', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'report', name: 'Daily / Monthly Report', icon: '📅', description: 'View reports', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'budget', name: 'Budget Tracker', icon: '🎯', description: 'Manage your budget', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'search-expense', name: 'Search Expenses', icon: '🔍', description: 'Search entries', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'reset-data', name: 'Reset Data', icon: '🔄', description: 'Clear all records', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'analytics', name: 'Graph & Analytics', icon: '📈', description: 'Visual data', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'spending-insights', name: 'Top Spending Insights', icon: '💡', description: 'Analyze spending', categoryId: 'expense-tracker', isNative: true),
    Tool(id: 'suggestions', name: 'Smart Suggestions', icon: '🧠', description: 'AI spending tips', categoryId: 'expense-tracker', isNative: true),

    // Survey Hub
    Tool(id: 'surveybuilder', name: 'Survey Builder', icon: '🛠️', description: 'Create surveys', categoryId: 'survey-hub', isNative: true),
    Tool(id: 'mysurveys', name: 'My Surveys', icon: '📊', description: 'View your surveys', categoryId: 'survey-hub', isNative: true),
    Tool(id: 'publicsurvey', name: 'Public Survey', icon: '🌐', description: 'Fill a survey', categoryId: 'survey-hub', isNative: true),

    // Utilities
    Tool(id: 'unitconverter', name: 'Unit Converter', icon: '📏', description: 'Convert units', categoryId: 'utilities', isNative: true),
    Tool(id: 'passwordgen', name: 'Password Generator', icon: '🔐', description: 'Generate passwords', categoryId: 'utilities', isNative: true),
    Tool(id: 'passwordsaver', name: 'Password Saver', icon: '🔒', description: 'Store passwords', categoryId: 'utilities', isNative: true),
    Tool(id: 'passwordstrength', name: 'Strength Checker', icon: '💪', description: 'Check security', categoryId: 'utilities', isNative: true),
    Tool(id: 'randomnamepicker', name: 'Random Name Picker', icon: '🎲', description: 'Pick a random name', categoryId: 'utilities', isNative: true),
    Tool(id: 'usernamegen', name: 'Username Generator', icon: '👤', description: 'Create unique usernames', categoryId: 'utilities', isNative: true),
    Tool(id: 'clipboardcleaner', name: 'Clipboard Cleaner', icon: '🧹', description: 'Clean text formatting', categoryId: 'utilities', isNative: true),

    // PDF Tools
    Tool(id: 'imagetopdf', name: 'Image to PDF', icon: '📄', description: 'Convert images to PDF', categoryId: 'pdf-tools', isNative: true),
    Tool(id: 'pdftoimage', name: 'PDF to Image', icon: '🖼️', description: 'Extract images from PDF', categoryId: 'pdf-tools', isNative: true),
    Tool(id: 'mergepdf', name: 'Merge PDF', icon: '📎', description: 'Merge multiple PDFs', categoryId: 'pdf-tools', isNative: true),
    Tool(id: 'rotatepdf', name: 'Rotate PDF', icon: '🔄', description: 'Rotate PDF pages', categoryId: 'pdf-tools', isNative: true),

    // Image Tools
    Tool(id: 'compressimage', name: 'Compress Image', icon: '📉', description: 'Reduce image size', categoryId: 'image-tools', isNative: true),
    Tool(id: 'imageinfo', name: 'Image Info', icon: 'ℹ️', description: 'View image metadata', categoryId: 'image-tools', isNative: true),

    // Math Tools
    Tool(id: 'discountcalc', name: 'Discount Calculator', icon: '🏷️', description: 'Calculate savings', categoryId: 'math-tools', isNative: true),
    Tool(id: 'percentagecalc', name: 'Percentage Calculator', icon: '%', description: 'Calculate percentage', categoryId: 'math-tools', isNative: true),
    Tool(id: 'primenumber', name: 'Prime Number Checker', icon: '🔢', description: 'Check prime numbers', categoryId: 'math-tools', isNative: true),
    Tool(id: 'palindrome', name: 'Palindrome Checker', icon: '🔄', description: 'Check palindromes', categoryId: 'math-tools', isNative: true),
    Tool(id: 'factorial', name: 'Factorial Calculator', icon: '❗', description: 'Calculate factorial', categoryId: 'math-tools', isNative: true),
    Tool(id: 'fibonacci', name: 'Fibonacci Generator', icon: '📈', description: 'Generate series', categoryId: 'math-tools', isNative: true),
    Tool(id: 'lcmhcf', name: 'LCM / HCF Calculator', icon: '➗', description: 'Find LCM and HCF', categoryId: 'math-tools', isNative: true),
    Tool(id: 'trianglechecker', name: 'Triangle Type Checker', icon: '📐', description: 'Check triangle type', categoryId: 'math-tools', isNative: true),
    Tool(id: 'distancecalc', name: 'Distance Calculator', icon: '📏', description: 'Find distance', categoryId: 'math-tools', isNative: true),
    Tool(id: 'equationsolver', name: 'Equation Solver', icon: '🔢', description: 'Solve equations', categoryId: 'math-tools', isNative: true),

    // Quick Tools
    Tool(id: 'texttospeech', name: 'Text to Speech', icon: '⚡', description: 'Convert text to sound', categoryId: 'quick-tools', isNative: true),
    Tool(id: 'wordcounter', name: 'Word Counter', icon: '🔢', description: 'Count words and characters', categoryId: 'quick-tools', isNative: true),
    Tool(id: 'textreverse', name: 'Text Reverser', icon: '🔄', description: 'Reverse your text', categoryId: 'quick-tools', isNative: true),
    Tool(id: 'caseconverter', name: 'Case Converter', icon: 'Aa', description: 'Change text case', categoryId: 'quick-tools', isNative: true),
    Tool(id: 'removeduplicates', name: 'Remove Duplicates', icon: '✨', description: 'Remove duplicate lines', categoryId: 'quick-tools', isNative: true),

    // Data Tools
    Tool(id: 'graphmaker', name: 'Graph Maker', icon: '📊', description: 'Create charts', categoryId: 'data-tools', isNative: true),
    Tool(id: 'averagecalculator', name: 'Average Calculator', icon: '📈', description: 'Calculate average', categoryId: 'data-tools', isNative: true),
    Tool(id: 'numbersorter', name: 'Number Sorter', icon: '🔢', description: 'Sort numbers', categoryId: 'data-tools', isNative: true),
    Tool(id: 'csvviewer', name: 'CSV Viewer', icon: '📑', description: 'View CSV files', categoryId: 'data-tools', isNative: true),

    // Time Tools
    Tool(id: 'daysbetween', name: 'Days Between Dates', icon: '📅', description: 'Calculate date gap', categoryId: 'time-tools', isNative: true),

    // Student Tools
    Tool(id: 'examcalc', name: 'Exam Marks Calculator', icon: '🎓', description: 'Calculate grades', categoryId: 'student-tools', isNative: true),

    // Planner Tools
    Tool(id: 'calendarviewer', name: 'Calendar Viewer', icon: '📅', description: 'View calendar', categoryId: 'planner-tools', isNative: true),
    Tool(id: 'dailyplanner', name: 'Daily Planner', icon: '🗓️', description: 'Plan your day', categoryId: 'planner-tools', isNative: true),
    Tool(id: 'reminderalert', name: 'Reminder Alert', icon: '🔔', description: 'Set reminders', categoryId: 'planner-tools', isNative: true),

    // Decision Tools
    Tool(id: 'spinwheel', name: 'Spin Wheel', icon: '🎡', description: 'Spin for decision', categoryId: 'decision-tools', isNative: true),
    Tool(id: 'yesnogerator', name: 'Yes / No Generator', icon: '🎯', description: 'Get a quick answer', categoryId: 'decision-tools', isNative: true),
    Tool(id: 'choicecomparator', name: 'Choice Comparator', icon: '⚖️', description: 'Compare options', categoryId: 'decision-tools', isNative: true),

    // Health Tools
    Tool(id: 'bmicalculator', name: 'BMI Calculator', icon: '⚖️', description: 'Body Mass Index', categoryId: 'health-utility-hub', isNative: true),
    Tool(id: 'drugdosage', name: 'Drug Dosage', icon: '💊', description: 'Dosage calculator', categoryId: 'health-utility-hub', isNative: true),
    Tool(id: 'ivdripcalc', name: 'IV Drip Rate', icon: '💧', description: 'Drip rate calculator', categoryId: 'health-utility-hub', isNative: true),
    Tool(id: 'medicinereminder', name: 'Medicine Reminder', icon: '⏰', description: 'Track medication', categoryId: 'health-utility-hub', isNative: true),

    // Web Tools
    Tool(id: 'urlencoder', name: 'URL Encoder / Decoder', icon: '🌐', description: 'Encode or decode URLs', categoryId: 'web-tools', isNative: true),
    Tool(id: 'urlextractor', name: 'URL Parameter Extractor', icon: '🔗', description: 'Extract parameters', categoryId: 'web-tools', isNative: true),
    Tool(id: 'metatagviewer', name: 'Meta Tag Viewer', icon: '🏷️', description: 'View meta tags', categoryId: 'web-tools', isNative: true),

    // AI Tools
    Tool(id: 'chatbot', name: 'AI Chatbot', icon: '💬', description: 'Chat with AI', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'text-improver', name: 'Text Improver', icon: '✍️', description: 'Refine your text', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'summarizer', name: 'Summarizer', icon: '📝', description: 'Summarize text', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'image-generator', name: 'Image Generator', icon: '🎨', description: 'Generate AI art', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'codehelper', name: 'Code Helper', icon: '💻', description: 'Explain or fix code', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'translator', name: 'AI Translator', icon: '🌍', description: 'Translate text', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'voiceassistant', name: 'Voice Assistant', icon: '🎙️', description: 'Voice powered AI', categoryId: 'ai-tools', isNative: true),
    Tool(id: 'docchecker', name: 'Document Checker', icon: '📄', description: 'Analyze documents', categoryId: 'ai-tools', isNative: true),
  ];

  static List<Tool> getToolsForCategory(String categoryId) {
    return tools.where((tool) => tool.categoryId == categoryId).toList();
  }
}
