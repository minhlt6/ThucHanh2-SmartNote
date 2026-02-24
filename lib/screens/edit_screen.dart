import 'package:flutter/material.dart';
import 'package:th2/models/note.dart';
import 'package:th2/services/note_storage.dart';

/// Màn hình soạn thảo / chỉnh sửa ghi chú.
/// Không có nút Save — ứng dụng tự động lưu khi người dùng thoát (Back).
class EditScreen extends StatefulWidget {
  final Note? note;

  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _storage = NoteStorage();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAndPop() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Nếu cả hai trống và là ghi chú mới -> không lưu
    if (title.isEmpty && content.isEmpty && widget.note == null) {
      Navigator.of(context).pop(false);
      return;
    }

    final now = DateTime.now();
    final id =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final note = Note(id: id, title: title, content: content, updatedAt: now);
    await _storage.addOrUpdate(note);
    // Trả về true để Home biết cần reload
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveAndPop();
        // We already popped inside _saveAndPop
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Soạn ghi chú'), elevation: 0),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Tiêu đề',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Viết ghi chú của bạn ở đây...',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
