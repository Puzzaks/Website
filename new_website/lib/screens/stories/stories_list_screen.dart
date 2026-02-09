import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/stories_service.dart';
import '../../models/story.dart';
import '../../widgets.dart'; // Keeping this if headerLine is used, check if it's used. headerLine IS used. list_screen line 74.

class StoriesListScreen extends StatefulWidget {
  const StoriesListScreen({super.key});

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final StoriesService _storiesService = StoriesService();
  late Future<List<Story>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _storiesFuture = _storiesService.fetchStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if mobile or desktop layout based on width
            // Using same breakpoint logic as main app (approx < 1060 for mobile)
            bool isMobile = constraints.maxWidth < 1060;

            return FutureBuilder<List<Story>>(
              future: _storiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading stories: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _storiesFuture = _storiesService.fetchStories();
                            });
                          },
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No stories found.'));
                }

                final stories = snapshot.data!;

                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 1200), // Max width for desktop content
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headerLine(
                                "Stories",
                                stories.length,
                                isMobile ? constraints.maxWidth : 1200,
                                Theme.of(context).textTheme.titleLarge?.color ??
                                    Colors.black),
                            const SizedBox(height: 20),
                            isMobile
                                ? _buildMobileList(
                                    stories, constraints.maxWidth)
                                : _buildDesktopGrid(
                                    stories, constraints.maxWidth),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileList(List<Story> stories, double width) {
    return Column(
      children: stories.map((story) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildStoryCard(story, width - 32, true),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopGrid(List<Story> stories, double width) {
    // Wrap to show cards
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: stories.map((story) {
        // Desktop card width approx 350 or 700 depending on design preference.
        // Let's use wide cards like 'newsCard' (700px) or standard project cards (350px).
        // User asked for "blog" style, maybe wide cards are better for readability?
        // Let's go with wide cards (700) if space permits, otherwise flexible.
        return _buildStoryCard(story, 700, false);
      }).toList(),
    );
  }

  Widget _buildStoryCard(Story story, double width, bool isMobile) {
    bool isLocal = story.isLocalImage;
    String imageUrl = story.image;
    if (isLocal && !imageUrl.startsWith('http')) {
      // Construct GitHub raw URL for assets
      imageUrl =
          'https://raw.githubusercontent.com/Puzzaks/Website/main/new_website/$imageUrl';
    }

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        child: InkWell(
          onTap: () {
            if (story.contentType == 'link') {
              launchUrl(Uri.parse(story.contentBody),
                  mode: LaunchMode.externalApplication);
            } else {
              // Use explicit ID for routing (stories.puzzak.page/:id)
              context.go('/${Uri.encodeComponent(story.id)}', extra: story);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (story.image.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback or placeholder
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      story.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Author not in new JSON, removing or defaulting
                        const Text(
                          "Puzzak", // Default author
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          // Simple date formatting
                          DateTime.fromMillisecondsSinceEpoch(story.date * 1000)
                              .toString()
                              .split(' ')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
