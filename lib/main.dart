import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/courses/presentation/cubit/courses_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ThaheenApp());
}

class ThaheenApp extends StatefulWidget {
  const ThaheenApp({super.key});

  @override
  State<ThaheenApp> createState() => _ThaheenAppState();
}

class _ThaheenAppState extends State<ThaheenApp> {
  Locale _locale = const Locale('ar');
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(
      onToggleLanguage: _toggleLanguage,
    );
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoursesCubit>(),
      child: MaterialApp.router(
        title: 'Thaheen LMS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: _locale,
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router,
      ),
    );
  }
}
