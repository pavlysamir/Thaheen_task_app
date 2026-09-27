import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter({VoidCallback? onToggleLanguage}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              'Thaheen LMS',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ],
  );
}
