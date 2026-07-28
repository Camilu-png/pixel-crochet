import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/import_pattern/presentation/import_screen.dart';
import '../../features/project/presentation/project_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/project/:id',
        name: 'project',
        builder: (context, state) => ProjectScreen(
          projectId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
