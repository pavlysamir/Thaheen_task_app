import 'package:flutter/material.dart';

enum AppLanguage {
  arabic('ar', 'العربية'),
  english('en', 'English');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'app_title': 'ذهين',
      'all_courses': 'المقررات الدراسية',
      'continue_watching': 'متابعة التعلّم',
      'resume_lesson': 'استئناف المشاهدة',
      'lessons_count': 'دروس',
      'completed': 'مكتمل',
      'in_progress': 'قيد المشاهدة',
      'not_started': 'لم يبدأ',
      'locked': 'مُقفل',
      'locked_message': 'يجب إكمال الدرس السابق أولاً لفتح هذا الدرس 🔒',
      'next_lesson': 'الدرس التالي',
      'playback_speed': 'سرعة التشغيل',
      'course_progress': 'نسبة الإنجاز',
      'no_courses': 'لا توجد مقررات دراسية متاحة حالياً',
      'loading': 'جاري التحميل...',
      'error_loading': 'حدث خطأ أثناء قراءة بيانات المقررات',
      'retry': 'إعادة المحاولة',
      'understood': 'حسناً',
      'close': 'إغلاق',
      'instructor_prefix': 'المحاضر:',
      'overview': 'نظرة عامة',
      'sections': 'الفصول والوحدات',
      'lesson_completed_toast': 'أحسنت! تم إكمال الدرس بنجاح 🎉',
    },
    'en': {
      'app_title': 'Thaheen',
      'all_courses': 'All Courses',
      'continue_watching': 'Continue Watching',
      'resume_lesson': 'Resume Lesson',
      'lessons_count': 'lessons',
      'completed': 'Completed',
      'in_progress': 'In Progress',
      'not_started': 'Not Started',
      'locked': 'Locked',
      'locked_message':
          'Please complete the previous lesson first to unlock this one 🔒',
      'next_lesson': 'Next Lesson',
      'playback_speed': 'Playback Speed',
      'course_progress': 'Progress',
      'no_courses': 'No courses available',
      'loading': 'Loading...',
      'error_loading': 'Failed to load courses data',
      'retry': 'Retry',
      'understood': 'Got it',
      'close': 'Close',
      'instructor_prefix': 'Instructor:',
      'overview': 'Overview',
      'sections': 'Sections & Lessons',
      'lesson_completed_toast': 'Great job! Lesson completed 🎉',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['ar']?[key] ??
        key;
  }

  String get appTitle => get('app_title');
  String get allCourses => get('all_courses');
  String get continueWatching => get('continue_watching');
  String get resumeLesson => get('resume_lesson');
  String get lessonsCount => get('lessons_count');
  String get completed => get('completed');
  String get inProgress => get('in_progress');
  String get notStarted => get('not_started');
  String get locked => get('locked');
  String get lockedMessage => get('locked_message');
  String get nextLesson => get('next_lesson');
  String get playbackSpeed => get('playback_speed');
  String get courseProgress => get('course_progress');
  String get noCourses => get('no_courses');
  String get loading => get('loading');
  String get errorLoading => get('error_loading');
  String get retry => get('retry');
  String get understood => get('understood');
  String get close => get('close');
  String get instructorPrefix => get('instructor_prefix');
  String get overview => get('overview');
  String get sections => get('sections');
  String get lessonCompletedToast => get('lesson_completed_toast');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
