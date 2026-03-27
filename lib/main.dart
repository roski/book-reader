import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'domain/entities/book.dart';
import 'domain/entities/reading_settings.dart';
import 'core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  // Register Hive adapters
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ReadingSettingsAdapter());

  // Open Hive boxes
  await Hive.openBox<Book>(AppConstants.booksBox);
  await Hive.openBox<ReadingSettings>(AppConstants.settingsBox);

  runApp(
    const ProviderScope(
      child: BookReaderApp(),
    ),
  );
}
