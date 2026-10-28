class Note {
  Note({
    required this.id,
    required this.title,
    required this.body,
    DateTime? modified,
  }) : modified = modified ?? DateTime.now();

  final String id;
  String title;
  String body;
  DateTime modified;

  void touch() {
    modified = DateTime.now();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'modified': modified.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        modified: DateTime.tryParse(json['modified'] as String? ?? '') ??
            DateTime.now(),
      );
}
