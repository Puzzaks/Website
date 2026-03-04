import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:system_theme/system_theme.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:new_website/backend.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:new_website/widgets/responsive_scaffold.dart';
import 'package:new_website/screens/home/home_screen.dart';
import 'package:new_website/screens/telemetry/telemetry_screen.dart';
import 'package:new_website/screens/projects/projects_screen.dart';
import 'package:new_website/screens/stories/stories_list_screen.dart';
import 'package:new_website/screens/stories/story_detail_screen.dart';
import 'package:new_website/models/story.dart';

// Create a key for the root navigator so we can push screens without the bottom nav bar (if needed later)
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorStoriesKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellStories');
final GlobalKey<NavigatorState> _shellNavigatorTelemetryKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellTelemetry');
final GlobalKey<NavigatorState> _shellNavigatorProjectsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProjects');

void main() {
  try {
    usePathUrlStrategy();
  } catch (_) {
    // Ignore "Invalid engine initialization state" during hot restart on web.
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => backend(),
      child: WebMain(),
    ),
  );
}

class WebMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<backend>(context, listen: false).start();
    });
    return WebMainRouter();
  }
}

class WebMainRouter extends StatefulWidget {
  @override
  State<WebMainRouter> createState() => _WebMainRouterState();
}

class _WebMainRouterState extends State<WebMainRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Determine subdomain
    String host = Uri.base.host;
    bool isStoriesSubdomain = host.startsWith('stories.') ||
        Uri.base.queryParameters.containsKey('stories_mode');
    bool isDashboardSubdomain =
        host.startsWith('dashboard.') || host.startsWith('telemetry.');
    bool isProjectsSubdomain = host.startsWith('projects.');

    // Dynamically assign branch paths based on the active subdomain.
    // This allows the router to render the correct tab at '/' without
    // forcing a URL redirect that appends the path to the address bar!
    String homePath =
        (isStoriesSubdomain || isDashboardSubdomain || isProjectsSubdomain)
            ? '/home'
            : '/';
    String storiesPath = isStoriesSubdomain ? '/' : '/stories';
    String dashboardPath = isDashboardSubdomain ? '/' : '/dashboard';
    String projectsPath = isProjectsSubdomain ? '/' : '/projects';

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        // StatefulShellRoute creates our bottom nav/sidebar wrapping the inner pages
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            return ResponsiveNavScaffold(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Home
            StatefulShellBranch(
              navigatorKey: _shellNavigatorHomeKey,
              routes: [
                GoRoute(
                  path: homePath,
                  builder: (BuildContext context, GoRouterState state) =>
                      const HomeScreen(),
                ),
              ],
            ),
            // Branch 1: Stories
            StatefulShellBranch(
              navigatorKey: _shellNavigatorStoriesKey,
              routes: [
                GoRoute(
                    path: storiesPath,
                    builder: (BuildContext context, GoRouterState state) =>
                        const StoriesListScreen(),
                    routes: [
                      // Story details sub-route.
                      // To handle direct `stories.puzzak.page/slug` we need an alias at root mapping
                      GoRoute(
                        path: ':slug',
                        builder: (context, state) {
                          final slug = state.pathParameters['slug']!;
                          final story = state.extra as Story?;
                          return StoryDetailScreen(slug: slug, storyObj: story);
                        },
                      ),
                    ]),
              ],
            ),
            // Branch 2: Telemetry
            StatefulShellBranch(
              navigatorKey: _shellNavigatorTelemetryKey,
              routes: [
                GoRoute(
                  path: dashboardPath,
                  builder: (BuildContext context, GoRouterState state) =>
                      const TelemetryScreen(),
                ),
              ],
            ),
            // Branch 3: Projects
            StatefulShellBranch(
              navigatorKey: _shellNavigatorProjectsKey,
              routes: [
                GoRoute(
                  path: projectsPath,
                  builder: (BuildContext context, GoRouterState state) =>
                      const ProjectsScreen(),
                  routes: [
                    GoRoute(
                      path: ':slug',
                      builder: (context, state) {
                        final slug = state.pathParameters['slug']!;
                        final story = state.extra as Story?;
                        return StoryDetailScreen(slug: slug, storyObj: story);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(builder: (context, backend, child) {
      return MaterialApp.router(
        routerConfig: _router,
        title: "Puzzak's",
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: backend.mode,
        debugShowCheckedModeBanner: false,
      );
    });
  }

  ThemeData _buildTheme(Brightness brightness) {
    const tealAccent = Color(0xFF009688);
    var baseScheme = ColorScheme.fromSeed(
      seedColor: tealAccent,
      brightness: brightness,
    );

    // Force background and surface to exactly match between nested material widgets
    final targetBackground = brightness == Brightness.light
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF141414);

    return ThemeData(
      colorScheme: baseScheme.copyWith(
        surface: targetBackground,
        primary: tealAccent,
        secondaryContainer: brightness == Brightness.dark
            ? tealAccent.withOpacity(0.3)
            : tealAccent.withOpacity(0.2),
        onSecondaryContainer:
            brightness == Brightness.dark ? Colors.white : tealAccent,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: targetBackground,
      // Automatically derive a nice contrasting card color from the dynamic surface palette
      cardColor: brightness == Brightness.light
          ? baseScheme.surfaceContainerHighest
          : baseScheme.surfaceContainer,
      iconTheme: IconThemeData(
        color: brightness == Brightness.light ? Colors.black87 : Colors.white,
      ),
    );
  }
}
