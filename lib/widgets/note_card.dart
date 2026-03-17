import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:th2/models/note.dart';

/// Widget hiển thị một thẻ ghi chú với giao diện bo góc, đổ bóng nhẹ.
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteCard({super.key, required this.note, this.onTap});

  static String _buildThreeLinePreview({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    final normalized = text.trimRight();
    if (normalized.isEmpty || maxWidth <= 0) return normalized;

    final fullPainter = TextPainter(
      text: TextSpan(text: normalized, style: style),
      textDirection: textDirection,
      maxLines: 3,
    )..layout(maxWidth: maxWidth);

    if (!fullPainter.didExceedMaxLines) {
      return normalized;
    }

    const suffix = '...';
    var low = 0;
    var high = normalized.length;

    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      final candidate = '${normalized.substring(0, mid).trimRight()}$suffix';

      final candidatePainter = TextPainter(
        text: TextSpan(text: candidate, style: style),
        textDirection: textDirection,
        maxLines: 3,
      )..layout(maxWidth: maxWidth);

      if (candidatePainter.didExceedMaxLines) {
        high = mid - 1;
      } else {
        low = mid;
      }
    }

    return '${normalized.substring(0, low).trimRight()}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final date = intl.DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt);
    final contentStyle = TextStyle(color: Colors.grey[700]);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? '(Không có tiêu đề)' : note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final preview = _buildThreeLinePreview(
                    text: note.content,
                    style: contentStyle,
                    maxWidth: constraints.maxWidth,
                    textDirection: Directionality.of(context),
                  );
                  return Text(
                    preview,
                    style: contentStyle,
                    maxLines: 3,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  );
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
