import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/entry.dart';

class StorageService {
  static const String entriesBoxName = 'entries';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EntryAdapter());
    }

    // Open boxes
    await Hive.openBox<Entry>(entriesBoxName);
    await Hive.openBox(settingsBoxName);
  }

  Box<Entry> get entriesBox => Hive.box<Entry>(entriesBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);

  // Entry operations
  Future<void> saveEntry(Entry entry) async {
    await entriesBox.put(entry.id, entry);
  }

  Entry? getEntry(String id) {
    return entriesBox.get(id);
  }

  List<Entry> getAllEntries() {
    return entriesBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteEntry(String id) async {
    await entriesBox.delete(id);
  }

  Future<void> updateEntry(Entry entry) async {
    await entriesBox.put(entry.id, entry);
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
}
