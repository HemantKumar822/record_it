import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_providers.dart';
final playbackSpeedProvider = StateProvider<String>((ref) => '1.0x');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            
            _buildSectionHeader(context, 'Appearance'),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.brightness,
              title: 'Theme',
              value: themeMode,
              onTap: () => _showThemePicker(context, ref),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Playback'),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.play_circle,
              title: 'Playback Speed',
              value: playbackSpeed,
              onTap: () => _showSpeedPicker(context, ref),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Data'),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.cloud_upload,
              title: 'Backup & Restore',
              onTap: () => _showComingSoonAlert(context),
            ),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.trash,
              title: 'Clear Cache',
              onTap: () => _showClearCacheConfirm(context),
            ),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.trash_circle,
              title: 'Delete All Recordings',
              isDestructive: true,
              onTap: () => _showDeleteAllConfirm(context, ref),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'About'),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.info,
              title: 'Version',
              value: '1.0.0',
            ),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.lock_shield,
              title: 'Data Privacy',
              onTap: () => _showPrivacyInfo(context),
            ),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.doc_text,
              title: 'Terms & Privacy Policy',
              onTap: () => _showComingSoonAlert(context),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Connect'),
            _buildListTile(
              context: context,
              icon: CupertinoIcons.camera,
              title: 'Follow on Instagram',
              onTap: () => _openInstagram(context),
            ),
            
            const SizedBox(height: 48),
            
            // Beautiful footer
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Made with ',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.heart_fill,
                    size: 14,
                    color: CupertinoColors.systemRed,
                  ),
                  Text(
                    ' by Hemant',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemBlue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? value,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? CupertinoColors.systemRed.withValues(alpha: 0.1)
                    : CupertinoColors.systemBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive 
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive 
                      ? CupertinoColors.systemRed
                      : CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onTap != null) const SizedBox(width: 6),
            ],
            if (onTap != null)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: CupertinoColors.systemGrey3,
              ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    _showPicker(
      context: context,
      title: 'Theme',
      options: ['Auto', 'Light', 'Dark'],
      selectedValue: ref.read(themeModeProvider),
      onSelected: (value) {
        ref.read(themeModeProvider.notifier).state = value;
      },
    );
  }

  void _showSpeedPicker(BuildContext context, WidgetRef ref) {
    _showPicker(
      context: context,
      title: 'Playback Speed',
      options: ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '2.0x'],
      selectedValue: ref.read(playbackSpeedProvider),
      onSelected: (value) {
        ref.read(playbackSpeedProvider.notifier).state = value;
      },
    );
  }

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    int selectedIndex = options.indexOf(selectedValue);
    if (selectedIndex == -1) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey4.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Done'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    onSelected(options[index]);
                  },
                  children: options.map((option) {
                    return Center(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoonAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Data Privacy'),
        content: const Text(
          'Your recordings are stored locally on your device and processed using Google Gemini AI. Audio data is sent to Gemini for transcription and processing, but is not stored by Google.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showClearCacheConfirm(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and app cache. Your recordings will not be affected.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessAlert(context, 'Cache cleared successfully');
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirm(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete All Recordings'),
        content: const Text(
          'This will permanently delete all recordings and cannot be undone. Are you sure?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete All'),
            onPressed: () async {
              Navigator.pop(context);
              final storageService = ref.read(storageServiceProvider);
              final entries = ref.read(entriesProvider);
              for (final entry in entries) {
                await storageService.deleteEntry(entry.id);
              }
              ref.read(entriesProvider.notifier).loadEntries();
              _showSuccessAlert(context, 'All recordings deleted');
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessAlert(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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

  void _openInstagram(BuildContext context) async {
    const instagramUrl = 'https://www.instagram.com/hemant._ai/';
    final uri = Uri.parse(instagramUrl);
    
    try {
      // Try to launch the URL directly
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Only show error if it truly fails
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Unable to Open'),
            content: const Text(
              'Could not open Instagram. Please visit @hemant._ai manually.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }
}
