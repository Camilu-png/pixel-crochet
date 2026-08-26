import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/more_patterns/presentation/more_patterns_screen.dart';
import '../../features/support/presentation/support_screen.dart';
import '../../features/suggest/presentation/suggest_screen.dart';
import '../../features/import_image/presentation/import_image_screen.dart';
import '../../features/import_pattern/presentation/import_screen.dart';
import '../../features/project/presentation/project_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/more-patterns',
            name: 'more-patterns',
            builder: (context, state) => const MorePatternsScreen(),
          ),
          GoRoute(
            path: '/support',
            name: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: '/suggest',
            name: 'suggest',
            builder: (context, state) => const SuggestScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/import-image',
        name: 'import-image',
        builder: (context, state) => const ImportImageScreen(),
      ),
      GoRoute(
        path: '/project/:id',
        name: 'project',
        builder: (context, state) =>
            ProjectScreen(projectId: state.pathParameters['id']!),
      ),
    ],
  );
});
