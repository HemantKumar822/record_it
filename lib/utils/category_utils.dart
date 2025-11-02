import 'package:flutter/cupertino.dart';

enum NoteCategory {
  meeting,
  idea,
  todo,
  journal,
  reminder,
  personal,
  work,
  note,
}

class CategoryUtils {
  // Auto-categorize based on content analysis
  static String categorizeContent(String title, String content) {
    final text = '$title $content'.toLowerCase();
    
    // Meeting indicators
    if (_containsAny(text, [
      'meeting', 'discussion', 'call', 'conference', 'agenda',
      'attendees', 'minutes', 'zoom', 'teams', 'meet'
    ])) {
      return 'Meeting';
    }
    
    // Todo/Task indicators
    if (_containsAny(text, [
      'todo', 'task', 'need to', 'must', 'should', 'have to',
      'deadline', 'due', 'action item', 'checklist'
    ])) {
      return 'Todo';
    }
    
    // Idea indicators
    if (_containsAny(text, [
      'idea', 'thought', 'concept', 'brainstorm', 'innovation',
      'maybe', 'what if', 'could', 'possibility'
    ])) {
      return 'Idea';
    }
    
    // Journal/Personal indicators
    if (_containsAny(text, [
      'today', 'feeling', 'felt', 'personal', 'diary',
      'reflection', 'grateful', 'learned', 'experience'
    ])) {
      return 'Journal';
    }
    
    // Reminder indicators
    if (_containsAny(text, [
      'remind', 'remember', 'don\'t forget', 'note to self',
      'important', 'later', 'follow up'
    ])) {
      return 'Reminder';
    }
    
    // Work indicators
    if (_containsAny(text, [
      'project', 'client', 'business', 'report', 'presentation',
      'proposal', 'budget', 'strategy', 'deadline', 'colleague'
    ])) {
      return 'Work';
    }
    
    // Personal indicators
    if (_containsAny(text, [
      'family', 'friend', 'home', 'weekend', 'vacation',
      'hobby', 'personal', 'birthday', 'anniversary'
    ])) {
      return 'Personal';
    }
    
    // Default category
    return 'Note';
  }
  
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
  
  // Get icon for category
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Meeting':
        return CupertinoIcons.person_3_fill;
      case 'Idea':
        return CupertinoIcons.lightbulb_fill;
      case 'Todo':
        return CupertinoIcons.checkmark_circle_fill;
      case 'Journal':
        return CupertinoIcons.book_fill;
      case 'Reminder':
        return CupertinoIcons.bell_fill;
      case 'Personal':
        return CupertinoIcons.heart_fill;
      case 'Work':
        return CupertinoIcons.briefcase_fill;
      default:
        return CupertinoIcons.doc_text_fill;
    }
  }
  
  // Get color for category
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Meeting':
        return const Color(0xFF007AFF); // Blue
      case 'Idea':
        return const Color(0xFFFFCC00); // Yellow
      case 'Todo':
        return const Color(0xFF34C759); // Green
      case 'Journal':
        return const Color(0xFFAF52DE); // Purple
      case 'Reminder':
        return const Color(0xFFFF9500); // Orange
      case 'Personal':
        return const Color(0xFFFF2D55); // Pink
      case 'Work':
        return const Color(0xFF5856D6); // Indigo
      default:
        return const Color(0xFF8E8E93); // Gray
    }
  }
  
  // Get all available categories
  static List<String> getAllCategories() {
    return [
      'Note',
      'Meeting',
      'Idea',
      'Todo',
      'Journal',
      'Reminder',
      'Personal',
      'Work',
    ];
  }
  
  // Get category display name
  static String getCategoryDisplayName(String category) {
    return category;
  }
}
