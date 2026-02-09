import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/stories_service.dart';
import '../../models/story.dart';

class StoryDetailScreen extends StatefulWidget {
  final String slug;
  final Story? storyObj; // Passed via 'extra' if available

  const StoryDetailScreen({super.key, required this.slug, this.storyObj});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final StoriesService _storiesService = StoriesService();
  late Future<String> _contentFuture;
  Story? _story;

  @override
  void initState() {
    super.initState();
    _story = widget.storyObj;

    if (_story != null) {
      _contentFuture = _storiesService.fetchStoryContent(_story!.contentBody);
    } else {
      _contentFuture = _loadStoryById(Uri.decodeComponent(widget.slug));
    }
  }

  Future<String> _loadStoryById(String id) async {
    try {
      final stories = await _storiesService.fetchStories();
      final match = stories.firstWhere((s) => s.id == id,
          orElse: () => Story(
              id: '',
              title: 'Story',
              description: '',
              pic: {},
              date: 0,
              content: {},
              tags: ''));

      if (match.id.isNotEmpty) {
        if (mounted) {
          setState(() {
            _story = match;
          });
        }
        return await _storiesService.fetchStoryContent(match.contentBody);
      } else {
        return '# Story Not Found\n\nThe story you are looking for does not exist.';
      }
    } catch (e) {
      return '# Error\n\nFailed to load story: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl = _story?.image;
    if (_story != null &&
        _story!.isLocalImage &&
        !imageUrl!.startsWith('http')) {
      imageUrl =
          'https://raw.githubusercontent.com/Puzzaks/Website/main/new_website/$imageUrl';
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        child: const Icon(Icons.arrow_back),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _contentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            String content =
                snapshot.data ?? '# Error\nCould not load content.';
            if (snapshot.hasError) {
              content = '# Error\n${snapshot.error}';
            }

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: 800), // Readable width for text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 21 / 9,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_story != null) ...[
                              Text(
                                _story!.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'By Puzzak • ${DateTime.fromMillisecondsSinceEpoch(_story!.date * 1000).toString().split(' ')[0]}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 32),
                            ],
                            MarkdownBody(
                              data: content,
                              selectable: true,
                              onTapLink: (text, href, title) {
                                if (href != null) {
                                  launchUrl(Uri.parse(href),
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                      Theme.of(context))
                                  .copyWith(
                                p: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 18, height: 1.6),
                                h1: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.5),
                                h2: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.4),
                                blockquote: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic),
                              ),
                            ),
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
