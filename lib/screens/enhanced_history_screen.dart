import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/entry.dart';
import '../utils/category_utils.dart';
import 'entry_detail_screen.dart';

class EnhancedHistoryScreen extends ConsumerStatefulWidget {
  const EnhancedHistoryScreen({super.key});

  @override
  ConsumerState<EnhancedHistoryScreen> createState() => _EnhancedHistoryScreenState();
}

class _EnhancedHistoryScreenState extends ConsumerState<EnhancedHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(filteredEntriesProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final favoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final groupedEntries = _groupEntriesByDate(entries);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('History'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search recordings...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, size: 18),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),

            // Filter and Sort chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Filter button
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: () => _showFilterSheet(context),
                    color: (selectedCategory != null || favoritesOnly)
                        ? CupertinoColors.systemBlue
                        : CupertinoColors.systemGrey5.resolveFrom(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.line_horizontal_3_decrease,
                          size: 16,
                          color: (selectedCategory != null || favoritesOnly)
                              ? CupertinoColors.white
                              : CupertinoColors.label.resolveFrom(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 14,
                            color: (selectedCategory != null || favoritesOnly)
                                ? CupertinoColors.white
                                : CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sort button
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: () => _showSortSheet(context),
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.sort_down,
                          size: 16,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getSortLabel(sortOption),
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Results count
                  Text(
                    '${entries.length} ${entries.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),

            // Active filters display
            if (selectedCategory != null || favoritesOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    if (selectedCategory != null)
                      _buildActiveFilterChip(
                        context,
                        selectedCategory,
                        () => ref.read(selectedCategoryFilterProvider.notifier).state = null,
                      ),
                    if (favoritesOnly)
                      _buildActiveFilterChip(
                        context,
                        'Favorites',
                        () => ref.read(showFavoritesOnlyProvider.notifier).state = false,
                      ),
                  ],
                ),
              ),

            // Results list
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            query.isNotEmpty ? CupertinoIcons.search : CupertinoIcons.doc_text,
                            size: 64,
                            color: CupertinoColors.systemGrey.resolveFrom(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            query.isNotEmpty ? 'No results found' : 'No recordings yet',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                          if (query.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 32, right: 32),
                              child: Text(
                                'Try different keywords or filters',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: CupertinoColors.systemGrey.resolveFrom(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          onRefresh: () async {
                            ref.read(entriesProvider.notifier).loadEntries();
                            await Future.delayed(const Duration(milliseconds: 500));
                          },
                        ),
                        ...groupedEntries.entries.map((group) {
                          return SliverMainAxisGroup(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                                  child: Text(
                                    group.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.systemGrey.resolveFrom(context),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final entry = group.value[index];
                                    return _buildEntryTile(context, entry);
                                  },
                                  childCount: group.value.length,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(BuildContext context, String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBlue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.systemBlue,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 16,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTile(BuildContext context, Entry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToDetail(context, entry),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CategoryUtils.getCategoryColor(entry.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CategoryUtils.getCategoryIcon(entry.category),
                  size: 20,
                  color: CategoryUtils.getCategoryColor(entry.category),
                ),
              ),
              const SizedBox(width: 14),

              // Entry details
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
                              fontSize: 16,
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
                        if (entry.durationSeconds > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${_formatDuration(entry.durationSeconds)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey.resolveFrom(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Filter by'),
        actions: [
          // Favorites filter
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(showFavoritesOnlyProvider.notifier).state = 
                  !ref.read(showFavoritesOnlyProvider);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (ref.read(showFavoritesOnlyProvider))
                  const Icon(CupertinoIcons.checkmark_alt, size: 20, color: CupertinoColors.activeBlue),
                if (ref.read(showFavoritesOnlyProvider))
                  const SizedBox(width: 8),
                const Text('Favorites Only'),
              ],
            ),
          ),
          
          // Category filters
          ...CategoryUtils.getAllCategories().map((category) {
            final isSelected = ref.read(selectedCategoryFilterProvider) == category;
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                ref.read(selectedCategoryFilterProvider.notifier).state = 
                    isSelected ? null : category;
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CategoryUtils.getCategoryIcon(category),
                    size: 20,
                    color: CategoryUtils.getCategoryColor(category),
                  ),
                  const SizedBox(width: 12),
                  Text(category),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(CupertinoIcons.checkmark_alt, size: 20, color: CupertinoColors.activeBlue),
                  ],
                ],
              ),
            );
          }),
          
          // Clear all filters
          if (ref.read(selectedCategoryFilterProvider) != null || ref.read(showFavoritesOnlyProvider))
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                ref.read(selectedCategoryFilterProvider.notifier).state = null;
                ref.read(showFavoritesOnlyProvider.notifier).state = false;
              },
              child: const Text('Clear All Filters'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Sort by'),
        actions: [
          _buildSortOption('date', 'Date (Newest First)', CupertinoIcons.calendar),
          _buildSortOption('duration', 'Duration', CupertinoIcons.time),
          _buildSortOption('alphabetical', 'Alphabetical', CupertinoIcons.textformat_abc),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = ref.read(sortOptionProvider) == value;
    return CupertinoActionSheetAction(
      onPressed: () {
        Navigator.pop(context);
        ref.read(sortOptionProvider.notifier).state = value;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.checkmark_alt, size: 20, color: CupertinoColors.activeBlue),
          ],
        ],
      ),
    );
  }

  String _getSortLabel(String sortOption) {
    switch (sortOption) {
      case 'duration':
        return 'Duration';
      case 'alphabetical':
        return 'A-Z';
      case 'date':
      default:
        return 'Date';
    }
  }

  Map<String, List<Entry>> _groupEntriesByDate(List<Entry> entries) {
    final Map<String, List<Entry>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      String dateKey;
      if (entryDate == today) {
        dateKey = 'TODAY';
      } else if (entryDate == yesterday) {
        dateKey = 'YESTERDAY';
      } else if (now.difference(entryDate).inDays < 7) {
        dateKey = DateFormat('EEEE').format(entry.timestamp).toUpperCase();
      } else {
        dateKey = DateFormat('MMMM d, y').format(entry.timestamp).toUpperCase();
      }

      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    return grouped;
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
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  void _navigateToDetail(BuildContext context, Entry entry) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EntryDetailScreen(entry: entry),
      ),
    );
  }
}
