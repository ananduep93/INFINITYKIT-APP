import 'package:flutter/material.dart';
import '../models/tool_models.dart';
import '../screens/tool_screen.dart';
import '../screens/todo_list_screen.dart';
import '../screens/unit_converter_screen.dart';
import '../screens/bmi_calculator_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/password_generator_screen.dart';
import '../screens/timer_screen.dart';
import '../screens/password_saver_screen.dart';
import '../screens/discount_calculator_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/percentage_calculator_screen.dart';
import '../screens/prime_checker_screen.dart';
import '../screens/palindrome_checker_screen.dart';
import '../screens/name_picker_screen.dart';
import '../screens/factorial_calculator_screen.dart';
import '../screens/yes_no_generator_screen.dart';
import '../screens/average_calculator_screen.dart';
import '../screens/fibonacci_generator_screen.dart';
import '../screens/lcm_hcf_calculator_screen.dart';
import '../screens/triangle_checker_screen.dart';
import '../screens/days_between_dates_screen.dart';
import '../screens/exam_marks_calculator_screen.dart';
import '../screens/number_sorter_screen.dart';
import '../screens/password_strength_screen.dart';
import '../screens/choice_comparator_screen.dart';
import '../screens/drug_dosage_screen.dart';
import '../screens/iv_drip_rate_screen.dart';
import '../screens/spin_wheel_screen.dart';
import '../screens/url_encoder_decoder_screen.dart';
import '../screens/daily_planner_screen.dart';
import '../screens/text_to_speech_screen.dart';
import '../screens/csv_viewer_screen.dart';
import '../screens/distance_calculator_screen.dart';
import '../screens/equation_solver_screen.dart';
import '../screens/graph_maker_screen.dart';
import '../screens/medicine_reminder_screen.dart';
import '../screens/ai_chatbot_screen.dart';
import '../screens/ai_text_tools_screen.dart';
import '../screens/ai_image_generator_screen.dart';
import '../screens/calendar_viewer_screen.dart';
import '../screens/survey_builder_screen.dart';
import '../screens/my_surveys_screen.dart';
import '../screens/public_survey_screen.dart';
import '../screens/image_to_pdf_screen.dart';
import '../screens/pdf_to_image_screen.dart';
import '../screens/merge_pdf_screen.dart';
import '../screens/rotate_pdf_screen.dart';
import '../screens/compress_image_screen.dart';
import '../screens/image_info_screen.dart';
import '../screens/budget_tracker_screen.dart';
import '../screens/expense_search_screen.dart';
import '../screens/expense_analytics_screen.dart';
import '../screens/reminder_alert_screen.dart';
import '../screens/spending_insights_screen.dart';
import '../screens/reset_data_screen.dart';
import '../screens/expense_report_screen.dart';
import '../screens/category_summary_screen.dart';
import '../screens/smart_suggestions_screen.dart';
import '../screens/url_param_extractor_screen.dart';
import '../screens/meta_tag_viewer_screen.dart';
import '../screens/username_generator_screen.dart';
import '../screens/word_counter_screen.dart';
import '../screens/text_reverser_screen.dart';
import '../screens/case_converter_screen.dart';
import '../screens/removeduplicates_screen.dart';
import '../screens/clipboard_cleaner_screen.dart';

class ToolNavigation {
  static void navigateToTool(BuildContext context, Tool tool) {
    if (tool.isNative) {
      final screen = _getNativeScreen(tool.id);
      if (screen != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ToolScreen(tool: tool)),
      );
    }
  }

  static Widget? _getNativeScreen(String toolId) {
    switch (toolId) {
      case 'todolist': return const ToDoListScreen();
      case 'unitconverter': return const UnitConverterScreen();
      case 'bmicalculator': return const BMICalculatorScreen();
      case 'notes': return const NotesScreen();
      case 'passwordgen': return const PasswordGeneratorScreen();
      case 'timer': return const TimerScreen();
      case 'passwordsaver': return const PasswordSaverScreen();
      case 'discount': return const DiscountCalculatorScreen();
      case 'expenseadd': return const AddExpenseScreen();
      case 'expenselist': return const ExpenseListScreen();
      case 'percentage': return const PercentageCalculatorScreen();
      case 'prime': return const PrimeCheckerScreen();
      case 'palindrome': return const PalindromeCheckerScreen();
      case 'namepicker': return const NamePickerScreen();
      case 'factorial': return const FactorialCalculatorScreen();
      case 'yesno': return const YesNoGeneratorScreen();
      case 'average': return const AverageCalculatorScreen();
      case 'fibonacci': return const FibonacciGeneratorScreen();
      case 'lcmhcf': return const LcmHcfCalculatorScreen();
      case 'triangle': return const TriangleCheckerScreen();
      case 'daysbetween': return const DaysBetweenDatesScreen();
      case 'exammarks': return const ExamMarksCalculatorScreen();
      case 'sorter': return const NumberSorterScreen();
      case 'passwordstrength': return const PasswordStrengthScreen();
      case 'choice': return const ChoiceComparatorScreen();
      case 'drugdosage': return const DrugDosageScreen();
      case 'ivdrip': return const IvDripRateScreen();
      case 'spinwheel': return const SpinWheelScreen();
      case 'urlencode': return const UrlEncoderDecoderScreen();
      case 'dailyplanner': return const DailyPlannerScreen();
      case 'texttospeech': return const TextToSpeechScreen();
      case 'csvviewer': return const CsvViewerScreen();
      case 'distance': return const DistanceCalculatorScreen();
      case 'equation': return const EquationSolverScreen();
      case 'graphmaker': return const GraphMakerScreen();
      case 'medreminder': return const MedicineReminderScreen();
      case 'chatbot': return const AiChatbotScreen();
      case 'improver': return const AiTextToolsScreen(title: 'AI Text Improver', hint: 'Enter text to improve...', type: 'improve');
      case 'summarizer': return const AiTextToolsScreen(title: 'AI Summarizer', hint: 'Enter text to summarize...', type: 'summarize');
      case 'codehelper': return const AiTextToolsScreen(title: 'AI Code Helper', hint: 'Paste code to explain or fix...', type: 'code');
      case 'translator': return const AiTextToolsScreen(title: 'AI Translator', hint: 'Enter text to translate...', type: 'translate');
      case 'voiceassistant': return const AiChatbotScreen();
      case 'docchecker': return const AiTextToolsScreen(title: 'Document Checker', hint: 'Paste document text to analyze...', type: 'chat');
      case 'imggen': return const AiImageGeneratorScreen();
      case 'calendar': return const CalendarViewerScreen();
      case 'surveybuilder': return const SurveyBuilderScreen();
      case 'mysurveys': return const MySurveysScreen();
      case 'publicsurvey': return const PublicSurveyScreen();
      case 'responseviewer': return const MySurveysScreen();
      case 'clipboardcleaner': return const ClipboardCleanerScreen();
      case 'imgtopdf': return const ImageToPdfScreen();
      case 'pdftoimg': return const PdfToImageScreen();
      case 'mergepdf': return const MergePdfScreen();
      case 'rotatepdf': return const RotatePdfScreen();
      case 'compressimg': return const CompressImageScreen();
      case 'imginfo': return const ImageInfoScreen();
      case 'budget': return const BudgetTrackerScreen();
      case 'search-expense': return const ExpenseSearchScreen();
      case 'analytics': return const ExpenseAnalyticsScreen();
      case 'reminder': return const ReminderAlertScreen();
      case 'spending-insights': return const SpendingInsightsScreen();
      case 'reset-data': return const ResetDataScreen();
      case 'report': return const ExpenseReportScreen();
      case 'categorysummary': return const CategorySummaryScreen();
      case 'suggestions': return const SmartSuggestionsScreen();
      case 'urlparam': return const UrlParamExtractorScreen();
      case 'metatag': return const MetaTagViewerScreen();
      case 'usernamegen': return const UsernameGeneratorScreen();
      case 'wordcounter': return const WordCounterScreen();
      case 'textreverse': return const TextReverserScreen();
      case 'caseconverter': return const CaseConverterScreen();
      case 'removeduplicates': return const RemoveDuplicatesScreen();
      default: return null;
    }
  }
}
