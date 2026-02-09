import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class StoriesService {
  // Base URL for fetching raw content from GitHub
  static const String _baseUrl = 'raw.githubusercontent.com';
  static const String _basePath = 'Puzzaks/Website/main/new_website/assets';

  // Cache to store stories list
  List<Story>? _cachedStories;

  // Cache to store story content
  final Map<String, String> _contentCache = {};

  /// Fetches the list of stories from index.json
  Future<List<Story>> fetchStories() async {
    if (_cachedStories != null) return _cachedStories!;

    try {
      final uri = Uri.https(_baseUrl, '$_basePath/news/index.json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> newsJson = data['news'] ?? [];
        final List<dynamic> projectsJson = data['projects'] ?? [];

        final allStories = [...newsJson, ...projectsJson];

        _cachedStories =
            allStories.map((json) => Story.fromJson(json)).toList();

        // Sort by date descending
        _cachedStories!.sort((a, b) => b.date.compareTo(a.date));

        return _cachedStories!;
      } else {
        throw Exception('Failed to load stories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stories: $e');
      return []; // Return empty list on error
    }
  }

  /// Fetches the markdown content of a specific story
  Future<String> fetchStoryContent(String fileName) async {
    if (_contentCache.containsKey(fileName)) return _contentCache[fileName]!;

    try {
      // If it's a local file path (e.g. stories/autostream.md)
      // We assume it's relative to 'assets/' base

      String cleanPath = fileName;
      // Handle potential prefixes if necessary, but index.json usually has relative paths
      // If content.body is "stories/autostream.md", we append it to base assets path.

      final uri = Uri.https(_baseUrl, '$_basePath/$cleanPath');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        String content = response.body;
        _contentCache[fileName] = content;
        return content;
      } else {
        throw Exception('Failed to load story content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching story content: $e');
      return '# Error Loading Story\n\nCould not load content. Please try again later.';
    }
  }
}
