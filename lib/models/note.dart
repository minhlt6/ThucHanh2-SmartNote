import 'dart:convert';

/// Model đại diện cho một ghi chú.
/// Tất cả thao tác lưu/đọc sẽ sử dụng JSON serialization.
class Note {
  String id;
  String title;
  String content;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  /// Tạo Note từ Map (JSON)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Chuyển Note thành Map để jsonEncode
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Hổ trợ chuyển danh sách JSON string thành danh sách Note
  static List<Note> listFromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
