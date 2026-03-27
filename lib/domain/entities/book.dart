import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  final String filePath;

  @HiveField(4)
  String? coverImagePath;

  @HiveField(5)
  double readingProgress; // 0.0 to 1.0

  @HiveField(6)
  DateTime? lastOpened;

  @HiveField(7)
  DateTime addedAt;

  @HiveField(8)
  String format; // 'epub' or 'fb2'

  @HiveField(9)
  int? totalPages;

  @HiveField(10)
  int? currentPage;

  @HiveField(11)
  String? lastCfiPosition; // EPUB CFI position

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    this.coverImagePath,
    this.readingProgress = 0.0,
    this.lastOpened,
    required this.addedAt,
    required this.format,
    this.totalPages,
    this.currentPage,
    this.lastCfiPosition,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    String? coverImagePath,
    double? readingProgress,
    DateTime? lastOpened,
    DateTime? addedAt,
    String? format,
    int? totalPages,
    int? currentPage,
    String? lastCfiPosition,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      readingProgress: readingProgress ?? this.readingProgress,
      lastOpened: lastOpened ?? this.lastOpened,
      addedAt: addedAt ?? this.addedAt,
      format: format ?? this.format,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      lastCfiPosition: lastCfiPosition ?? this.lastCfiPosition,
    );
  }
}
