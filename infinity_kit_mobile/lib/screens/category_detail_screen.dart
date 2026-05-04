import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tool_models.dart';
import '../services/tool_data_service.dart';
import '../utils/theme.dart';
import 'tool_screen.dart';
import 'todo_list_screen.dart';
import 'unit_converter_screen.dart';
import 'bmi_calculator_screen.dart';
import 'notes_screen.dart';
import 'password_generator_screen.dart';
import 'timer_screen.dart';
import 'password_saver_screen.dart';
import 'discount_calculator_screen.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'percentage_calculator_screen.dart';
import 'prime_checker_screen.dart';
import 'palindrome_checker_screen.dart';
import 'name_picker_screen.dart';
import 'factorial_calculator_screen.dart';
import 'yes_no_generator_screen.dart';
import 'average_calculator_screen.dart';
import 'fibonacci_generator_screen.dart';
import 'lcm_hcf_calculator_screen.dart';
import 'triangle_checker_screen.dart';
import 'days_between_dates_screen.dart';
import 'exam_marks_calculator_screen.dart';
import 'number_sorter_screen.dart';
import 'password_strength_screen.dart';
import 'choice_comparator_screen.dart';
import 'drug_dosage_screen.dart';
import 'iv_drip_rate_screen.dart';
import 'spin_wheel_screen.dart';
import 'url_encoder_decoder_screen.dart';
import 'daily_planner_screen.dart';
import 'text_to_speech_screen.dart';
import 'csv_viewer_screen.dart';
import 'distance_calculator_screen.dart';
import 'equation_solver_screen.dart';
import 'graph_maker_screen.dart';
import 'medicine_reminder_screen.dart';
import 'ai_chatbot_screen.dart';
import 'ai_text_tools_screen.dart';
import 'ai_image_generator_screen.dart';
import 'calendar_viewer_screen.dart';
import 'survey_builder_screen.dart';
import 'my_surveys_screen.dart';
import 'public_survey_screen.dart';
import 'image_to_pdf_screen.dart';
import 'pdf_to_image_screen.dart';
import 'merge_pdf_screen.dart';
import 'rotate_pdf_screen.dart';
import 'compress_image_screen.dart';
import 'image_info_screen.dart';
import 'budget_tracker_screen.dart';
import 'expense_search_screen.dart';
import 'expense_analytics_screen.dart';
import 'reminder_alert_screen.dart';
import 'spending_insights_screen.dart';
import 'reset_data_screen.dart';
import 'expense_report_screen.dart';
import 'category_summary_screen.dart';
import 'smart_suggestions_screen.dart';
import 'url_param_extractor_screen.dart';
import 'meta_tag_viewer_screen.dart';
import 'username_generator_screen.dart';
import 'word_counter_screen.dart';
import 'text_reverser_screen.dart';
import 'case_converter_screen.dart';
import 'removeduplicates_screen.dart';
import 'clipboard_cleaner_screen.dart';

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
          if (tool.isNative) {
            _navigateToNativeTool(context, tool.id);
          } else {
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ToolScreen(tool: tool)),
            );
          }
        },
      ),
    );
  }

  void _navigateToNativeTool(BuildContext context, String toolId) {
    Widget screen;
    switch (toolId) {
      case 'todolist': screen = const ToDoListScreen(); break;
      case 'unitconverter': screen = const UnitConverterScreen(); break;
      case 'bmicalculator': screen = const BMICalculatorScreen(); break;
      case 'notes': screen = const NotesScreen(); break;
      case 'passwordgen': screen = const PasswordGeneratorScreen(); break;
      case 'timer': screen = const TimerScreen(); break;
      case 'passwordsaver': screen = const PasswordSaverScreen(); break;
      case 'discount': screen = const DiscountCalculatorScreen(); break;
      case 'expenseadd': screen = const AddExpenseScreen(); break;
      case 'expenselist': screen = const ExpenseListScreen(); break;
      case 'percentage': screen = const PercentageCalculatorScreen(); break;
      case 'prime': screen = const PrimeCheckerScreen(); break;
      case 'palindrome': screen = const PalindromeCheckerScreen(); break;
      case 'namepicker': screen = const NamePickerScreen(); break;
      case 'factorial': screen = const FactorialCalculatorScreen(); break;
      case 'yesno': screen = const YesNoGeneratorScreen(); break;
      case 'average': screen = const AverageCalculatorScreen(); break;
      case 'fibonacci': screen = const FibonacciGeneratorScreen(); break;
      case 'lcmhcf': screen = const LcmHcfCalculatorScreen(); break;
      case 'triangle': screen = const TriangleCheckerScreen(); break;
      case 'daysbetween': screen = const DaysBetweenDatesScreen(); break;
      case 'exammarks': screen = const ExamMarksCalculatorScreen(); break;
      case 'sorter': screen = const NumberSorterScreen(); break;
      case 'passwordstrength': screen = const PasswordStrengthScreen(); break;
      case 'choice': screen = const ChoiceComparatorScreen(); break;
      case 'drugdosage': screen = const DrugDosageScreen(); break;
      case 'ivdrip': screen = const IvDripRateScreen(); break;
      case 'spinwheel': screen = const SpinWheelScreen(); break;
      case 'urlencode': screen = const UrlEncoderDecoderScreen(); break;
      case 'dailyplanner': screen = const DailyPlannerScreen(); break;
      case 'texttospeech': screen = const TextToSpeechScreen(); break;
      case 'csvviewer': screen = const CsvViewerScreen(); break;
      case 'distance': screen = const DistanceCalculatorScreen(); break;
      case 'equation': screen = const EquationSolverScreen(); break;
      case 'graphmaker': screen = const GraphMakerScreen(); break;
      case 'medreminder': screen = const MedicineReminderScreen(); break;
      case 'chatbot': screen = const AiChatbotScreen(); break;
      case 'improver': screen = const AiTextToolsScreen(title: 'AI Text Improver', hint: 'Enter text to improve...', type: 'improve'); break;
      case 'summarizer': screen = const AiTextToolsScreen(title: 'AI Summarizer', hint: 'Enter text to summarize...', type: 'summarize'); break;
      case 'codehelper': screen = const AiTextToolsScreen(title: 'AI Code Helper', hint: 'Paste code to explain or fix...', type: 'code'); break;
      case 'translator': screen = const AiTextToolsScreen(title: 'AI Translator', hint: 'Enter text to translate...', type: 'translate'); break;
      case 'voiceassistant': screen = const AiChatbotScreen(); break;
      case 'docchecker': screen = const AiTextToolsScreen(title: 'Document Checker', hint: 'Paste document text to analyze...', type: 'chat'); break;
      case 'imggen': screen = const AiImageGeneratorScreen(); break;
      case 'calendar': screen = const CalendarViewerScreen(); break;
      case 'surveybuilder': screen = const SurveyBuilderScreen(); break;
      case 'mysurveys': screen = const MySurveysScreen(); break;
      case 'publicsurvey': screen = const PublicSurveyScreen(); break;
      case 'responseviewer': screen = const MySurveysScreen(); break;
      case 'clipboardcleaner': screen = const ClipboardCleanerScreen(); break;
      case 'imgtopdf': screen = const ImageToPdfScreen(); break;
      case 'pdftoimg': screen = const PdfToImageScreen(); break;
      case 'mergepdf': screen = const MergePdfScreen(); break;
      case 'rotatepdf': screen = const RotatePdfScreen(); break;
      case 'compressimg': screen = const CompressImageScreen(); break;
      case 'imginfo': screen = const ImageInfoScreen(); break;
      case 'budget': screen = const BudgetTrackerScreen(); break;
      case 'search-expense': screen = const ExpenseSearchScreen(); break;
      case 'analytics': screen = const ExpenseAnalyticsScreen(); break;
      case 'reminder': screen = const ReminderAlertScreen(); break;
      case 'spending-insights': screen = const SpendingInsightsScreen(); break;
      case 'reset-data': screen = const ResetDataScreen(); break;
      case 'report': screen = const ExpenseReportScreen(); break;
      case 'categorysummary': screen = const CategorySummaryScreen(); break;
      case 'suggestions': screen = const SmartSuggestionsScreen(); break;
      case 'urlparam': screen = const UrlParamExtractorScreen(); break;
      case 'metatag': screen = const MetaTagViewerScreen(); break;
      case 'usernamegen': screen = const UsernameGeneratorScreen(); break;
      case 'wordcounter': screen = const WordCounterScreen(); break;
      case 'textreverse': screen = const TextReverserScreen(); break;
      case 'caseconverter': screen = const CaseConverterScreen(); break;
      case 'removeduplicates': screen = const RemoveDuplicatesScreen(); break;
      default: return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
