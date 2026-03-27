import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(context),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBookInfo(context),
              ),
              _buildMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (book.coverImagePath != null) {
      final file = File(book.coverImagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            width: 70,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderCover(context),
          ),
        );
      }
    }
    return _buildPlaceholderCover(context);
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.book,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        size: 36,
      ),
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          book.author,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        _buildProgress(context),
        const SizedBox(height: 4),
        Text(
          '${(book.readingProgress * 100).round()}% read',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context) {
    return LinearPercentIndicator(
      percent: book.readingProgress.clamp(0.0, 1.0),
      lineHeight: 6,
      padding: EdgeInsets.zero,
      backgroundColor:
          Theme.of(context).colorScheme.surfaceContainerHighest,
      progressColor: Theme.of(context).colorScheme.primary,
      barRadius: const Radius.circular(3),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
