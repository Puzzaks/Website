import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class StoriesService {
  // Base URL for fetching raw content from GitHub
  static const String _baseUrl = 'raw.githubusercontent.com';
  static const String _basePath = 'Puzzaks/Website/main/new_website/assets';

  // Cache to store lists
  List<Story>? _cachedNews;
  List<Story>? _cachedProjects;

  // Cache to store story content
  final Map<String, String> _contentCache = {};

  Future<void> _fetchIndexData() async {
    if (_cachedNews != null && _cachedProjects != null) return;

    try {
      final uri = Uri.https(_baseUrl, '$_basePath/news/index.json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> newsJson = data['news'] ?? [];
        final List<dynamic> projectsJson = data['projects'] ?? [];

        _cachedNews = newsJson.map((json) => Story.fromJson(json)).toList();
        _cachedNews!.sort((a, b) => b.date.compareTo(a.date));

        _cachedProjects =
            projectsJson.map((json) => Story.fromJson(json)).toList();
        _cachedProjects!.sort((a, b) => b.date.compareTo(a.date));
      } else {
        throw Exception('Failed to load index.json: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching index.json: $e');
      _cachedNews = [];
      _cachedProjects = [];
    }
  }

  /// Fetches the list of news from index.json
  Future<List<Story>> fetchNews() async {
    await _fetchIndexData();
    return _cachedNews ?? [];
  }

  /// Fetches the list of projects from index.json
  Future<List<Story>> fetchProjects() async {
    await _fetchIndexData();
    return _cachedProjects ?? [];
  }

  /// Keep this for backwards compatibility if needed, though we will phase it out
  Future<List<Story>> fetchStories() async {
    await _fetchIndexData();
    final allStories = [...?_cachedNews, ...?_cachedProjects];
    allStories.sort((a, b) => b.date.compareTo(a.date));
    return allStories;
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
