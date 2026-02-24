import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:th2/models/note.dart';

/// Service quản lý lưu/đọc ghi chú bằng SharedPreferences.
class NoteStorage {
  static const String _kNotesKey = 'smart_notes_v1';

  /// Load tất cả ghi chú từ SharedPreferences.
  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Ghi đè toàn bộ danh sách ghi chú.
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_kNotesKey, raw);
  }

  /// Thêm hoặc cập nhật một ghi chú (nếu id trùng thì cập nhật, ngược lại thêm mới vào đầu danh sách).
  Future<void> addOrUpdate(Note note) async {
    final notes = await loadNotes();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.insert(0, note);
    }
    await saveNotes(notes);
  }

  /// Xóa ghi chú theo id.
  Future<void> delete(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n.id == id);
    await saveNotes(notes);
  }
}
