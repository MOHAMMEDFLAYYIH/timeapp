import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_title': 'Task Manager',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'on': 'On',
      'off': 'Off',
      'notifications': 'Notifications',
      'notifications_subtitle': 'Receive task reminders',
      'preferences': 'Preferences',
      'language': 'Language',
      'select_language': 'Select Language',
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'help_support': 'Help & Support',
      'log_out': 'Log Out',
      'log_out_confirmation': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'update': 'Update',
      'create': 'Create',
      'edit': 'Edit',
      'error': 'Error',
      'loading': 'Loading...',
      'try_again': 'Try Again',
      'something_went_wrong': 'Something went wrong',
      'undo': 'Undo',
      'edit_profile': 'Edit Profile',
      'save': 'Save',
      'name': 'Name',
      'email': 'Email',
      'enter_name': 'Enter your name',
      'enter_email': 'Enter your email',
      'save_changes': 'Save Changes',
      'contact_support': 'Contact Support',
      'frequently_asked_questions': 'Frequently Asked Questions',
      'send_feedback': 'Send Feedback',
      'feedback_hint': 'Tell us what you think...',

      // Navigation
      'nav_tasks': 'Tasks',
      'nav_categories': 'Categories',
      'nav_analytics': 'Analytics',
      'nav_settings': 'Settings',

      // Task List
      'loading_tasks': 'Loading tasks...',
      'no_tasks_yet': 'No tasks yet',
      'add_first_task': 'Add your first task to get started',
      'add_task': 'Add Task',
      'pending': 'Pending',
      'completed': 'Completed',
      'task_deleted': 'Task deleted',
      'all': 'All',

      // Category Management
      'loading_categories': 'Loading categories...',
      'no_categories': 'No categories',
      'create_categories_desc': 'Create categories to organize your tasks',
      'add_category': 'Add Category',
      'edit_category': 'Edit Category',
      'new_category': 'New Category',
      'category_name': 'Category Name',
      'category_hint': 'e.g., Work, Personal, Shopping',
      'enter_name_error': 'Please enter a name',
      'color': 'Color',
      'icon': 'Icon',
      'category_updated': 'Category updated',
      'category_created': 'Category created',
      'delete_category': 'Delete Category',
      'delete_category_confirm':
          'Are you sure you want to delete "{name}"? Tasks in this category will not be deleted.',
      'category_deleted': 'Category deleted',
      'tap_to_edit': 'Tap to edit',

      // Add/Edit Task
      'new_task': 'New Task',
      'edit_task': 'Edit Task',
      'task_title': 'Task Title',
      'task_hint': 'What needs to be done?',
      'enter_title_error': 'Please enter a title',
      'description_optional': 'Description (optional)',
      'description_hint': 'Add more details...',
      'no_categories_available':
          'No categories available. Please create one first.',
      'category': 'Category',
      'due_date': 'Due Date',
      'no_due_date': 'No due date',
      'update_task': 'Update Task',
      'create_task': 'Create Task',
      'task_updated': 'Task updated',
      'task_created': 'Task created',
      'select_category_error': 'Please select a category',

      // Motivational
      'quote_1': 'Your clean slate awaits',
      'quote_2': 'Ready to conquer the day?',
      'quote_3': 'A fresh start begins here',
      'quote_4': 'Time to make things happen',

      // Analytics
      'analytics_title': 'Analytics',
      'loading_analytics': 'Loading analytics...',
      'no_data_yet': 'No data yet',
      'complete_tasks_desc': 'Complete some tasks to see your analytics',
      'weekly_productivity': 'Weekly Productivity',
      'this_week': 'This Week',
      'tasks_completed': 'tasks completed',
      'insight_outstanding':
          'Outstanding! You completed {count} tasks this week.',
      'insight_good': 'Good progress! Keep the momentum going.',
      'insight_motivated': 'You\'ve got this! Small steps lead to big results.',
      'insight_start': 'Start completing tasks to track your progress!',
      'daily_progress': 'Daily Progress',
      'total_tasks': 'Total Tasks',
      'recent_activity': 'Recent Activity',
      'ago_m': '{m}m ago',
      'ago_h': '{h}h ago',
      'ago_d': '{d}d ago',
    },
    'ar': {
      // General
      'app_title': 'مدير المهام',
      'settings': 'الإعدادات',
      'appearance': 'المظهر',
      'dark_mode': 'الوضع الليلي',
      'on': 'مفعل',
      'off': 'معطل',
      'notifications': 'الإشعارات',
      'notifications_subtitle': 'تلقي تذكيرات المهام',
      'preferences': 'التفضيلات',
      'language': 'اللغة',
      'select_language': 'اختر اللغة',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'privacy_policy': 'سياسة الخصوصية',
      'help_support': 'المساعدة والدعم',
      'log_out': 'تسجيل الخروج',
      'log_out_confirmation': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'update': 'تحديث',
      'create': 'إنشاء',
      'edit': 'تعديل',
      'error': 'خطأ',
      'loading': 'جاري التحميل...',
      'try_again': 'حاول مرة أخرى',
      'something_went_wrong': 'حدث خطأ ما',
      'undo': 'تراجع',
      'edit_profile': 'تعديل الملف الشخصي',
      'save': 'حفظ',
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'enter_name': 'أدخل اسمك',
      'enter_email': 'أدخل بريدك الإلكتروني',
      'save_changes': 'حفظ التغييرات',
      'contact_support': 'تواصل مع الدعم',
      'frequently_asked_questions': 'الأسئلة الشائعة',
      'send_feedback': 'أرسل ملاحظاتك',
      'feedback_hint': 'أخبرنا برأيك...',

      // Navigation
      'nav_tasks': 'المهام',
      'nav_categories': 'التصنيفات',
      'nav_analytics': 'التحليلات',
      'nav_settings': 'الإعدادات',

      // Task List
      'loading_tasks': 'جاري تحميل المهام...',
      'no_tasks_yet': 'لا توجد مهام بعد',
      'add_first_task': 'أضف مهمتك الأولى للبدء',
      'add_task': 'إضافة مهمة',
      'pending': 'قيد الانتظار',
      'completed': 'مكتملة',
      'task_deleted': 'تم حذف المهمة',
      'all': 'الكل',

      // Category Management
      'loading_categories': 'جاري تحميل التصنيفات...',
      'no_categories': 'لا توجد تصنيفات',
      'create_categories_desc': 'أنشئ تصنيفات لتنظيم مهامك',
      'add_category': 'إضافة تصنيف',
      'edit_category': 'تعديل التصنيف',
      'new_category': 'تصنيف جديد',
      'category_name': 'اسم التصنيف',
      'category_hint': 'مثال: العمل، الشخصي، التسوق',
      'enter_name_error': 'الرجاء إدخال اسم',
      'color': 'اللون',
      'icon': 'الأيقونة',
      'category_updated': 'تم تحديث التصنيف',
      'category_created': 'تم إنشاء التصنيف',
      'delete_category': 'حذف التصنيف',
      'delete_category_confirm':
          'هل أنت متأكد أنك تريد حذف "{name}"؟ لن يتم حذف المهام الموجودة في هذا التصنيف.',
      'category_deleted': 'تم حذف التصنيف',
      'tap_to_edit': 'اضغط للتعديل',

      // Add/Edit Task
      'new_task': 'مهمة جديدة',
      'edit_task': 'تعديل المهمة',
      'task_title': 'عنوان المهمة',
      'task_hint': 'ما الذي يجب القيام به؟',
      'enter_title_error': 'الرجاء إدخال عنوان',
      'description_optional': 'الوصف (اختياري)',
      'description_hint': 'أضف المزيد من التفاصيل...',
      'no_categories_available':
          'لا توجد تصنيفات متاحة. الرجاء إنشاء تصنيف أولاً.',
      'category': 'التصنيف',
      'due_date': 'تاريخ الاستحقاق',
      'no_due_date': 'لا يوجد تاريخ استحقاق',
      'update_task': 'تحديث المهمة',
      'create_task': 'إنشاء المهمة',
      'task_updated': 'تم تحديث المهمة',
      'task_created': 'تم إنشاء المهمة',
      'select_category_error': 'الرجاء اختيار تصنيف',

      // Motivational
      'quote_1': 'صفحة جديدة بانتظارك',
      'quote_2': 'مستعد لغزو اليوم؟',
      'quote_3': 'بداية جديدة تبدأ هنا',
      'quote_4': 'حان الوقت لتحقيق الإنجازات',

      // Analytics
      'analytics_title': 'التحليلات',
      'loading_analytics': 'جاري تحميل التحليلات...',
      'no_data_yet': 'لا توجد بيانات بعد',
      'complete_tasks_desc': 'أكمل بعض المهام لرؤية التحليلات',
      'weekly_productivity': 'الإنتاجية الأسبوعية',
      'this_week': 'هذا الأسبوع',
      'tasks_completed': 'مهمة مكتملة',
      'insight_outstanding': 'مذهل! لقد أكملت {count} مهمة هذا الأسبوع.',
      'insight_good': 'تقدم جيد! حافظ على الزخم.',
      'insight_motivated':
          'أنت قادر على ذلك! خطوات صغيرة تؤدي إلى نتائج كبيرة.',
      'insight_start': 'ابدأ بإكمال المهام لتتبع تقدمك!',
      'daily_progress': 'التقدم اليومي',
      'total_tasks': 'إجمالي المهام',
      'recent_activity': 'النشاط الأخير',
      'ago_m': 'منذ {m} دقيقة',
      'ago_h': 'منذ {h} ساعة',
      'ago_d': 'منذ {d} يوم',
    },
  };

  String get(String key, [Map<String, String>? params]) {
    String text = _localizedValues[locale.languageCode]?[key] ?? key;
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }
    return text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension methods for easier access
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
