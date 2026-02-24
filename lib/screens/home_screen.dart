import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:th2/models/note.dart';
import 'package:th2/services/note_storage.dart';
import 'package:th2/screens/edit_screen.dart';
import 'package:th2/widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = NoteStorage();
  List<Note> _notes = [];
  List<Note> _filtered = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final all = await _storage.loadNotes();
    setState(() {
      _notes = all;
      _applyFilter(_searchController.text);
    });
  }

  void _applyFilter(String q) {
    final text = q.trim().toLowerCase();
    if (text.isEmpty) {
      _filtered = List.from(_notes);
    } else {
      _filtered = _notes
          .where((n) => n.title.toLowerCase().contains(text))
          .toList();
    }
  }

  Future<bool?> _openEditor({Note? note}) async {
    final res = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => EditScreen(note: note)));
    if (res == true) {
      await _loadNotes();
    }
    return res;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: const Text('OK'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Note - Lê Tiến Minh - 2351060465',
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  setState(() {
                    _applyFilter(v);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tiêu đề...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final note = _filtered[index];
                          return Dismissible(
                            key: Key(note.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              final ok = await _confirmDelete(context);
                              if (ok) {
                                await _storage.delete(note.id);
                                await _loadNotes();
                              }
                              return ok;
                            },
                            background: Container(
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: NoteCard(
                              note: note,
                              onTap: () => _openEditor(note: note),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.4,
            child: Icon(
              Icons.note_alt_outlined,
              size: 120,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có ghi chú nào, hãy tạo mới nhé!',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
