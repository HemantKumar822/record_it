import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/category_utils.dart';

class AIService {
  late final GenerativeModel _model;
  
  static const String _apiKey = 'AIzaSyAAgttLd4q95eCA4OKgylmIO2iGCNyMxTk';

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Step 1: Transcribe audio to text
  Future<String> transcribeAudio(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      if (!audioFile.existsSync()) {
        throw Exception('Audio file not found: $audioPath');
      }
      
      final audioBytes = await audioFile.readAsBytes();

      final prompt = '''Generate a complete, detailed transcript of this audio.
Include all spoken words verbatim, including filler words and natural speech patterns.
Do not add any formatting or interpretation - just the raw transcript.''';

      // Determine audio MIME type from file extension
      String mimeType = 'audio/aac';
      if (audioPath.endsWith('.m4a')) {
        mimeType = 'audio/mp4';
      } else if (audioPath.endsWith('.mp3')) {
        mimeType = 'audio/mpeg';
      } else if (audioPath.endsWith('.wav')) {
        mimeType = 'audio/wav';
      }

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, audioBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text?.trim() ?? '';
    } catch (e) {
      throw Exception('Transcription failed: $e');
    }
  }

  /// Step 2: Polish the transcript into a formatted note
  Future<String> polishTranscript(String rawTranscript) async {
    try {
      final prompt = '''You are an expert editor. Take this raw voice transcription and create a polished, well-formatted note.

Rules:
1. Remove ALL filler words (um, uh, like, you know, etc.)
2. Fix grammar and sentence structure naturally
3. Format any lists or bullet points using markdown
4. Add paragraph breaks for readability
5. Preserve the original meaning and tone
6. If there are key thoughts or action items, structure them clearly
7. Use markdown formatting (headers, bold, lists, etc.)
8. Keep it concise but complete

Raw Transcript:
$rawTranscript

Return ONLY the polished note in markdown format. No preamble or explanation.''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text?.trim() ?? rawTranscript;
    } catch (e) {
      throw Exception('Polishing failed: $e');
    }
  }

  /// Extract a title from the polished note
  Future<String> generateTitle(String polishedNote) async {
    try {
      final prompt = '''Based on this note, generate a short, descriptive title (max 5 words).
The title should capture the main topic or theme.
Return ONLY the title, nothing else.

Note:
$polishedNote''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      String title = response.text?.trim() ?? 'Untitled Note';
      // Ensure title isn't too long
      if (title.split(' ').length > 5) {
        title = title.split(' ').take(5).join(' ');
      }
      return title;
    } catch (e) {
      return 'Untitled Note';
    }
  }

  /// Process audio end-to-end: transcribe, polish, and generate title
  Future<ProcessedAudio> processAudio(String audioPath) async {
    // Step 1: Transcribe
    final rawTranscript = await transcribeAudio(audioPath);
    
    if (rawTranscript.isEmpty) {
      throw Exception('Transcription returned empty result');
    }

    // Step 2: Polish
    final polishedNote = await polishTranscript(rawTranscript);
    
    // Step 3: Generate title
    final title = await generateTitle(polishedNote);
    
    // Step 4: Auto-categorize based on content
    final category = CategoryUtils.categorizeContent(title, polishedNote);

    return ProcessedAudio(
      rawTranscript: rawTranscript,
      polishedNote: polishedNote,
      title: title,
      category: category,
    );
  }
}

class ProcessedAudio {
  final String rawTranscript;
  final String polishedNote;
  final String title;
  final String category;

  ProcessedAudio({
    required this.rawTranscript,
    required this.polishedNote,
    required this.title,
    required this.category,
  });
}
