import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../backend.dart';

class ResponsiveNavScaffold extends StatelessWidget {
  const ResponsiveNavScaffold({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ResponsiveNavScaffold'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(builder: (context, backendProvider, child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Update backend dimensions (keeping existing logic for compatibility)
          // We defer this so it doesn't happen during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            backendProvider.context = context;
            backendProvider.scaffoldWidth = constraints.maxWidth;
            backendProvider.scaffoldHeight = constraints.maxHeight;
          });

          bool isWide = constraints.maxWidth >= 800;

          if (isWide) {
            return _buildDesktopLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      );
    });
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Stories',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Telemetry',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Projects',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // Floating Navigation Rail Container
            SizedBox(
              width: 100, // Slightly wider width
              child: Align(
                alignment: Alignment.center, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 8.0),
                  child: IntrinsicHeight(
                    // Constrain height to children
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: NavigationRail(
                        backgroundColor: Colors
                            .transparent, // Let Container handle background
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: _goBranch,
                        labelType: NavigationRailLabelType
                            .all, // Switched back to all for better look in floating bubble
                        destinations: const [
                          NavigationRailDestination(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.home_outlined),
                            ),
                            selectedIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.home),
                            ),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.article_outlined),
                            ),
                            selectedIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.article),
                            ),
                            label: Text('Stories'),
                          ),
                          NavigationRailDestination(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.analytics_outlined),
                            ),
                            selectedIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.analytics),
                            ),
                            label: Text('Telemetry'),
                          ),
                          NavigationRailDestination(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.work_outline),
                            ),
                            selectedIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.work),
                            ),
                            label: Text('Projects'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
