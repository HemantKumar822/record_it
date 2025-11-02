import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entry.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/audio_recording_service.dart';

// Services
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

final audioRecordingServiceProvider = Provider<AudioRecordingService>((ref) {
  return AudioRecordingService();
});

// Entries State
final entriesProvider = StateNotifierProvider<EntriesNotifier, List<Entry>>((ref) {
  return EntriesNotifier(ref.read(storageServiceProvider));
});

class EntriesNotifier extends StateNotifier<List<Entry>> {
  final StorageService _storageService;

  EntriesNotifier(this._storageService) : super([]) {
    loadEntries();
  }

  void loadEntries() {
    state = _storageService.getAllEntries();
  }

  Future<void> addEntry(Entry entry) async {
    await _storageService.saveEntry(entry);
    loadEntries();
  }

  Future<void> updateEntry(Entry entry) async {
    await _storageService.updateEntry(entry);
    loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _storageService.deleteEntry(id);
    loadEntries();
  }
}

// Recording State
final recordingStateProvider = StateNotifierProvider<RecordingStateNotifier, RecordingState>((ref) {
  return RecordingStateNotifier(ref.read(audioRecordingServiceProvider));
});

class RecordingStateNotifier extends StateNotifier<RecordingState> {
  final AudioRecordingService _audioService;

  RecordingStateNotifier(this._audioService) : super(RecordingState.idle) {
    _audioService.stateStream.listen((newState) {
      state = newState;
    });
  }
}

// Current recording path
final currentRecordingPathProvider = StateProvider<String?>((ref) => null);

// Processing state
final processingStateProvider = StateProvider<bool>((ref) => false);

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filter options
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

// Sort option: 'date', 'duration', 'alphabetical'
final sortOptionProvider = StateProvider<String>((ref) => 'date');

// Theme mode provider
final themeModeProvider = StateProvider<String>((ref) => 'Auto');

// Filtered and sorted entries
final filteredEntriesProvider = Provider<List<Entry>>((ref) {
  final entries = ref.watch(entriesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(selectedCategoryFilterProvider);
  final favoritesOnly = ref.watch(showFavoritesOnlyProvider);
  final sortOption = ref.watch(sortOptionProvider);

  // Filter entries
  var filtered = entries.where((entry) {
    // Search filter
    final matchesSearch = query.isEmpty ||
        entry.title.toLowerCase().contains(query) ||
        entry.polishedNote.toLowerCase().contains(query) ||
        entry.rawTranscript.toLowerCase().contains(query) ||
        entry.category.toLowerCase().contains(query);
    
    // Category filter
    final matchesCategory = categoryFilter == null || entry.category == categoryFilter;
    
    // Favorites filter
    final matchesFavorites = !favoritesOnly || entry.isFavorite;
    
    return matchesSearch && matchesCategory && matchesFavorites;
  }).toList();

  // Sort entries
  switch (sortOption) {
    case 'duration':
      filtered.sort((a, b) => b.durationSeconds.compareTo(a.durationSeconds));
      break;
    case 'alphabetical':
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case 'date':
    default:
      // Sort by pinned first, then by date
      filtered.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.timestamp.compareTo(a.timestamp);
      });
  }

  return filtered;
});

// Recent entries (last 3)
final recentEntriesProvider = Provider<List<Entry>>((ref) {
  final entries = ref.watch(entriesProvider);
  return entries.take(3).toList();
});

// Amplitude stream for waveform
final amplitudeStreamProvider = StreamProvider<double>((ref) {
  final audioService = ref.watch(audioRecordingServiceProvider);
  return audioService.amplitudeStream;
});
