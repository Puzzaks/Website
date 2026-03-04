import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/stories_service.dart';
import '../../models/story.dart';
import '../../widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final StoriesService _storiesService = StoriesService();
  late Future<List<Story>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _storiesService.fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            double padding = 32;
            double elementWidth = 710; // Standard grid box
            double spacing = 20;

            int columns =
                (maxWidth / (elementWidth + spacing)).floor().clamp(1, 2);
            double contentWidth =
                (elementWidth * columns) + (spacing * (columns - 1));

            if (maxWidth < elementWidth + padding) {
              contentWidth = maxWidth - padding;
            }

            double cardWidth =
                maxWidth < elementWidth + padding ? contentWidth : elementWidth;

            return FutureBuilder<List<Story>>(
              future: _projectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                }

                final projects = snapshot.data!;

                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headerLine(
                                "Projects",
                                projects.length,
                                contentWidth,
                                Theme.of(context).textTheme.titleLarge?.color ??
                                    Colors.black),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: spacing,
                              runSpacing: spacing,
                              children: projects
                                  .map((project) =>
                                      _buildStoryCard(project, cardWidth))
                                  .toList(),
                            )
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

  Widget _buildStoryCard(Story project, double width) {
    bool isLocal = project.isLocalImage;
    String imageUrl = project.image;
    if (isLocal && !imageUrl.startsWith('http')) {
      imageUrl =
          'https://raw.githubusercontent.com/Puzzaks/Website/main/new_website/$imageUrl';
    }

    return SizedBox(
      width: width,
      child: Card(
        color: Theme.of(context).cardColor,
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        child: InkWell(
          onTap: () {
            if (project.contentType == 'link') {
              launchUrl(Uri.parse(project.contentBody),
                  mode: LaunchMode.externalApplication);
            } else {
              // Direct navigation to project details, properly prepended
              context.go('/projects/${Uri.encodeComponent(project.id)}',
                  extra: project);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.image.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
                      project.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Puzzak",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          DateTime.fromMillisecondsSinceEpoch(
                                  project.date * 1000)
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
