import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/entry.dart';
import '../utils/category_utils.dart';
import '../utils/responsive.dart';
import 'entry_detail_screen.dart';
import 'enhanced_history_screen.dart';
import 'settings_screen.dart';
import '../widgets/morphing_recording_control.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final recentEntries = ref.watch(recentEntriesProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            // Main content - stays visible and interactive
            CustomScrollView(
              slivers: [
                // Pull to refresh
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    ref.read(entriesProvider.notifier).loadEntries();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                ),
                
                // App branding and greeting section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.spacing(AppSpacing.xl),
                      context.spacing(20),
                      context.spacing(AppSpacing.xl),
                      context.spacing(AppSpacing.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Navigation buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _showHistory(context),
                              child: Container(
                                padding: EdgeInsets.all(context.spacing(10)),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                                  borderRadius: BorderRadius.circular(context.spacing(12)),
                                ),
                                child: Icon(
                                  CupertinoIcons.list_bullet,
                                  size: context.responsive.iconSize(AppIconSize.lg),
                                  color: CupertinoColors.label.resolveFrom(context),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _showSettings(context),
                              child: Container(
                                padding: EdgeInsets.all(context.spacing(10)),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                                  borderRadius: BorderRadius.circular(context.spacing(12)),
                                ),
                                child: Icon(
                                  CupertinoIcons.gear,
                                  size: context.responsive.iconSize(AppIconSize.lg),
                                  color: CupertinoColors.label.resolveFrom(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacing(AppSpacing.xxl)),
                        
                        // App name/branding
                        Text(
                          'Record It',
                          style: TextStyle(
                            fontSize: context.sp(AppFontSize.display),
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label.resolveFrom(context),
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: context.spacing(AppSpacing.sm)),
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: context.sp(AppFontSize.title),
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.systemGrey.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Processing indicator - removed from here, will show on button

                // Recent entries section - always show when available
                if (recentEntries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                Text(
                                  'Recent',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.label.resolveFrom(context),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showHistory(context),
                                  child: const Text(
                                    'See All',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Recent entries list - always show when available
                      if (recentEntries.isEmpty)
                        SliverToBoxAdapter(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 100),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.doc_text,
                                      size: 48,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'No recordings yet',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.label.resolveFrom(context),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Tap the record button below to capture your first thought',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: CupertinoColors.systemGrey.resolveFrom(context),
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = recentEntries[index];
                              return _buildEntryCard(context, entry);
                            },
                            childCount: recentEntries.length,
                          ),
                        ),

                      // Bottom spacing for floating button
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 120),
                      ),
                    ],
                  ),

            // Morphing recording control - always visible at bottom center
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: const MorphingRecordingControl(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, Entry entry) {
    // Extract first line or first sentence for preview
    String preview = entry.polishedNote;
    if (preview.isNotEmpty) {
      // Remove markdown formatting for cleaner preview
      preview = preview
          .replaceAll(RegExp(r'[#*_\[\]`]'), '')
          .replaceAll(RegExp(r'\n+'), ' ')
          .trim();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: child,
            ),
          );
        },
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _navigateToDetail(context, entry),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CategoryUtils.getCategoryColor(entry.category).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CategoryUtils.getCategoryIcon(entry.category),
                        size: 18,
                        color: CategoryUtils.getCategoryColor(entry.category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.label.resolveFrom(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (entry.isPinned || entry.isFavorite) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (entry.isPinned)
                                        const Icon(
                                          CupertinoIcons.pin_fill,
                                          size: 14,
                                          color: CupertinoColors.systemOrange,
                                        ),
                                      if (entry.isPinned && entry.isFavorite)
                                        const SizedBox(width: 5),
                                      if (entry.isFavorite)
                                        const Icon(
                                          CupertinoIcons.star_fill,
                                          size: 14,
                                          color: CupertinoColors.systemYellow,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CategoryUtils.getCategoryColor(entry.category).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: CategoryUtils.getCategoryColor(entry.category),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(entry.timestamp),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.systemGrey.resolveFrom(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    preview,
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon 👋';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening 🌆';
    } else {
      return 'Good night 🌙';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _navigateToDetail(BuildContext context, Entry entry) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EntryDetailScreen(entry: entry),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const EnhancedHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0); // Slide from left
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}
