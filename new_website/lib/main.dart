import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:system_theme/system_theme.dart';
import 'dart:core';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:new_website/backend.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:new_website/desktop.dart';
import 'package:new_website/mobile.dart';
import 'package:new_website/screens/stories/stories_list_screen.dart';
import 'package:new_website/screens/stories/story_detail_screen.dart';
import 'package:new_website/models/story.dart';

void main() {
  usePathUrlStrategy();
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
    WidgetsFlutterBinding.ensureInitialized();
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
    // Determine subdomain (primitive check)
    // In a real deployed environment, we check Uri.base.host
    // localhost for testing might need a query param override
    String host = Uri.base.host;
    // Check for query param 'stories_mode' in the initial load URL
    // We should look at Uri.base, not state (which isn't available yet)
    // But GoRouter hasn't parsed it yet? Uri.base gives the browser URL.
    bool isStoriesSubdomain = host.startsWith('stories.') ||
        Uri.base.queryParameters.containsKey('stories_mode');

    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            if (isStoriesSubdomain) {
              return const StoriesListScreen();
            } else {
              return const MainSiteLayout();
            }
          },
          routes: [
            // Only allow direct slug access on stories subdomain
            if (isStoriesSubdomain)
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
    // Shared theme builder to keep consistent with original
    var baseScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      accentColor: Colors.teal,
      cardColor: brightness == Brightness.light
          ? Colors.teal.withValues(alpha: 100)
          : Colors.teal.withValues(alpha: 220),
      backgroundColor: Colors.teal,
      errorColor: Colors.orange,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: baseScheme,
      useMaterial3: true,
      cardColor: brightness == Brightness.light
          ? Colors.white
          : Colors.teal.withValues(alpha: 198),
      iconTheme: IconThemeData(
        color: brightness == Brightness.light ? Colors.black : Colors.white,
      ),
    );
  }
}

class MainSiteLayout extends StatelessWidget {
  const MainSiteLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final backendProvider =
                Provider.of<backend>(context, listen: false);
            backendProvider.context = context;
            backendProvider.scaffoldWidth = constraints.maxWidth;
            backendProvider.scaffoldHeight = constraints.maxHeight;
            if (backendProvider.scaffoldWidth < 1060) {
              return const MobilePage();
            } else {
              return const DesktopPage();
            }
          },
        ),
      ),
    );
  }
}
