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
  final ScrollController _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text("Return to the list"),
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
              controller: _scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 800), // Readable width for text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image
                      SizedBox(
                        height: 15,
                      ),
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
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
                                      color: Colors.white,
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
                                      color: Colors.white,
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
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                        height: 1.6),
                                h1: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1.5),
                                h2: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4),
                                blockquote: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic),
                                a: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                        decorationThickness: 2,
                                        decorationStyle:
                                            TextDecorationStyle.solid),
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
