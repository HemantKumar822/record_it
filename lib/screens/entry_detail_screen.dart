import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/entry.dart';
import '../providers/app_providers.dart';
import '../widgets/audio_player_widget.dart';
import 'image_viewer_screen.dart';

class EntryDetailScreen extends ConsumerStatefulWidget {
  final Entry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends ConsumerState<EntryDetailScreen> {
  bool _showTranscript = false;
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _noteController = TextEditingController(text: widget.entry.polishedNote);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current entry from provider for live updates
    final entries = ref.watch(entriesProvider);
    final currentEntry = entries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isEditing) ...[
              // Favorite button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _toggleFavorite,
                child: Icon(
                  currentEntry.isFavorite 
                    ? CupertinoIcons.star_fill 
                    : CupertinoIcons.star,
                  color: currentEntry.isFavorite 
                    ? CupertinoColors.systemYellow 
                    : null,
                ),
              ),
              // Pin button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _togglePin,
                child: Icon(
                  currentEntry.isPinned 
                    ? CupertinoIcons.pin_fill 
                    : CupertinoIcons.pin,
                  color: currentEntry.isPinned 
                    ? CupertinoColors.systemOrange 
                    : null,
                ),
              ),
              // Edit button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Reload current values into controllers
                  setState(() {
                    _titleController.text = currentEntry.title;
                    _noteController.text = currentEntry.polishedNote;
                    _isEditing = true;
                  });
                },
                child: const Icon(CupertinoIcons.pencil),
              ),
              // Share button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _shareEntry,
                child: const Icon(CupertinoIcons.share),
              ),
              // Delete button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _deleteEntry,
                child: const Icon(CupertinoIcons.delete),
              ),
            ] else ...[
              // Add image button (in edit mode)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showImageSourcePicker,
                child: const Icon(CupertinoIcons.photo_on_rectangle),
              ),
              // Cancel editing
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Get current entry to reset controllers
                  final entries = ref.read(entriesProvider);
                  final currentEntry = entries.firstWhere(
                    (e) => e.id == widget.entry.id,
                    orElse: () => widget.entry,
                  );
                  
                  setState(() {
                    _isEditing = false;
                    _titleController.text = currentEntry.title;
                    _noteController.text = currentEntry.polishedNote;
                  });
                },
                child: const Icon(CupertinoIcons.xmark),
              ),
              // Save changes
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveEntry,
                child: const Icon(CupertinoIcons.check_mark),
              ),
            ],
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            // Title
            if (_isEditing)
              CupertinoTextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
                placeholder: 'Title',
              )
            else
              GestureDetector(
                onTap: () => setState(() => _isEditing = true),
                child: Text(
                  currentEntry.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Metadata
            Text(
              _formatMetadata(),
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),

            const SizedBox(height: 24),

            // Polished Note Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing)
                    CupertinoTextField(
                      controller: _noteController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 15),
                      placeholder: 'Note content',
                    )
                  else
                    currentEntry.polishedNote.isNotEmpty
                        ? MarkdownBody(
                            data: currentEntry.polishedNote,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 15,
                                color: CupertinoColors.label.resolveFrom(context),
                                height: 1.5,
                              ),
                              h1: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.label.resolveFrom(context),
                              ),
                              h2: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.label.resolveFrom(context),
                              ),
                              listBullet: TextStyle(
                                fontSize: 15,
                                color: CupertinoColors.label.resolveFrom(context),
                              ),
                            ),
                          )
                        : Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.systemGrey.resolveFrom(context),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                ],
              ),
            ),

            // Images section
            if (currentEntry.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Attached Images',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: currentEntry.imageUrls.map((imagePath) {
                  return GestureDetector(
                    onTap: () => _viewImage(imagePath),
                    onLongPress: _isEditing ? () => _removeImage(imagePath) : null,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(imagePath),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(imagePath),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.destructiveRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.xmark,
                                  size: 16,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Raw Transcript Toggle
            if (currentEntry.rawTranscript.isNotEmpty)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _showTranscript = !_showTranscript;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Raw Transcript',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _showTranscript
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 16,
                    ),
                  ],
                ),
              ),

            // Raw Transcript Content
            if (_showTranscript && currentEntry.rawTranscript.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemGrey4.resolveFrom(context),
                    width: 1,
                  ),
                ),
                child: Text(
                  currentEntry.rawTranscript,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    height: 1.5,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Audio Player
            AudioPlayerWidget(audioPath: widget.entry.audioPath),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatMetadata() {
    final dateFormat = DateFormat('EEEE, MMM d · h:mm a');
    final formattedDate = dateFormat.format(widget.entry.timestamp);
    final duration = _formatDuration(widget.entry.durationSeconds);
    return '$formattedDate\n$duration';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes min $remainingSeconds sec';
  }

  Future<void> _saveEntry() async {
    // Get current entry from provider to preserve all fields (images, favorites, pins, etc.)
    final entries = ref.read(entriesProvider);
    final currentEntry = entries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );
    
    final updatedEntry = currentEntry.copyWith(
      title: _titleController.text,
      polishedNote: _noteController.text,
    );
    
    await ref.read(entriesProvider.notifier).updateEntry(updatedEntry);
    
    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      _showAlert('Saved', 'Entry updated successfully');
    }
  }

  Future<void> _toggleFavorite() async {
    // Get current entry state
    final entries = ref.read(entriesProvider);
    final currentEntry = entries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );
    
    final updatedEntry = currentEntry.copyWith(isFavorite: !currentEntry.isFavorite);
    await ref.read(entriesProvider.notifier).updateEntry(updatedEntry);
    HapticFeedback.mediumImpact();
  }

  Future<void> _togglePin() async {
    // Get current entry state
    final entries = ref.read(entriesProvider);
    final currentEntry = entries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );
    
    final updatedEntry = currentEntry.copyWith(isPinned: !currentEntry.isPinned);
    await ref.read(entriesProvider.notifier).updateEntry(updatedEntry);
    HapticFeedback.mediumImpact();
  }

  Future<void> _deleteEntry() async {
    final confirmed = await _showConfirmDialog(
      'Delete Entry',
      'Are you sure you want to delete this entry? This cannot be undone.',
    );

    if (confirmed == true) {
      await ref.read(entriesProvider.notifier).deleteEntry(widget.entry.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _shareEntry() async {
    // Get current entry from provider for accurate data
    final entries = ref.read(entriesProvider);
    final currentEntry = entries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );
    
    final content = '''${currentEntry.title}

${currentEntry.polishedNote}

---
Recorded on ${DateFormat('MMM d, yyyy').format(currentEntry.timestamp)}
''';

    await Clipboard.setData(ClipboardData(text: content));
    
    if (mounted) {
      _showAlert('Copied', 'Entry copied to clipboard');
    }
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourcePicker() async {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Add Image'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera, size: 20),
                SizedBox(width: 12),
                Text('Take Photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, size: 20),
                SizedBox(width: 12),
                Text('Choose from Gallery'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Get current entry from provider for live data
        final entries = ref.read(entriesProvider);
        final currentEntry = entries.firstWhere(
          (e) => e.id == widget.entry.id,
          orElse: () => widget.entry,
        );
        
        final updatedImageUrls = List<String>.from(currentEntry.imageUrls)
          ..add(pickedFile.path);
        
        final updatedEntry = currentEntry.copyWith(imageUrls: updatedImageUrls);
        await ref.read(entriesProvider.notifier).updateEntry(updatedEntry);
        
        HapticFeedback.mediumImpact();
        
        if (mounted) {
          _showAlert('Success', 'Image added successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        _showAlert('Error', 'Failed to add image: ${e.toString()}');
      }
    }
  }

  void _viewImage(String imagePath) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ImageViewerScreen(imagePath: imagePath),
      ),
    );
  }

  Future<void> _removeImage(String imagePath) async {
    final confirmed = await _showConfirmDialog(
      'Remove Image',
      'Are you sure you want to remove this image?',
    );

    if (confirmed == true) {
      // Get current entry from provider for live data
      final entries = ref.read(entriesProvider);
      final currentEntry = entries.firstWhere(
        (e) => e.id == widget.entry.id,
        orElse: () => widget.entry,
      );
      
      final updatedImageUrls = List<String>.from(currentEntry.imageUrls)
        ..remove(imagePath);
      
      final updatedEntry = currentEntry.copyWith(imageUrls: updatedImageUrls);
      await ref.read(entriesProvider.notifier).updateEntry(updatedEntry);
      
      // Optionally delete the file
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore file deletion errors
      }
      
      HapticFeedback.mediumImpact();
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
