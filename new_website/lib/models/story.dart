class Story {
  final String id;
  final String title;
  final String description;
  final Map<String, dynamic> pic;
  final int date; // Timestamp
  final Map<String, dynamic> content;
  final String tags;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.pic,
    required this.date,
    required this.content,
    required this.tags,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pic: json['pic'] ?? {'url': '', 'local': false},
      date: json['date'] ?? 0,
      content: json['content'] ?? {'type': 'text', 'body': ''},
      tags: json['tags'] ?? '',
    );
  }

  String get image => pic['url'] ?? '';
  bool get isLocalImage => pic['local'] ?? false;
  String get contentType => content['type'] ?? 'text';
  String get contentBody => content['body'] ?? '';
}
