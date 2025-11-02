# Record It 🎙️# Record It



**Transform spoken thoughts into polished notes instantly with AI-powered transcription and smart organization.**> Turn spoken thoughts into written clarity — instantly, privately, beautifully.



## 📱 FeaturesA Flutter app that records your voice, transcribes it using Google Gemini AI, and transforms it into polished notes with beautiful formatting.



- **🎤 One-Tap Recording** - Start recording with a single tap, intuitive morphing control## Features

- **🤖 AI-Powered Processing** - Google Gemini AI automatically transcribes and polishes your notes

- **📁 Smart Organization** - Auto-categorization into 8 categories (Meeting, Idea, Todo, Journal, etc.)✨ **One-Tap Recording** - Start recording in under 1 second

- **🔍 Advanced Search** - Fast search across titles, content, and transcripts🎙️ **Live Waveform** - Real-time audio visualization while recording

- **⭐ Favorites & Pins** - Mark important entries and pin them to the top🤖 **AI Processing** - Two-step Gemini AI processing:

- **🎨 Categories** - Color-coded category system with smart keyword detection  - Step 1: Transcribe audio to text

- **📸 Image Attachments** - Attach images from camera or gallery  - Step 2: Polish transcript into formatted notes

- **🌗 Dark Mode** - Full dark mode support with auto-detection📝 **Markdown Formatting** - Beautiful, readable notes with automatic formatting

- **💾 Local Storage** - All data stored locally with Hive database🎵 **Audio Playback** - Listen to your original recordings

- **🔒 Privacy First** - No cloud storage, your data stays on your device🔍 **Search & History** - Find any entry instantly

📱 **iOS-Style UI** - Cupertino widgets for native iOS feel

## 🏗️ Technical Stack🔒 **Privacy-First** - Offline recording, local storage

💾 **Encrypted Storage** - Hive database with encryption

- **Framework**: Flutter 3.35.7

- **State Management**: Riverpod 2.4.9## Setup Instructions

- **Database**: Hive (Local NoSQL)

- **AI**: Google Gemini 2.5 Flash### Prerequisites

- **Audio**: Flutter Sound + AudioPlayers

- **UI**: Cupertino (iOS-style design)- Flutter 3.0 or higher

- Dart 3.0 or higher

## 🚀 Getting Started- A Google Gemini API key



### Prerequisites### 1. Get a Gemini API Key



- Flutter SDK 3.0.0 or higher1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)

- Google Gemini API key2. Sign in with your Google account

3. Create a new API key

### Setup4. Copy the API key



1. Install dependencies### 2. Configure the API Key

```bash

flutter pub getOpen `lib/services/ai_service.dart` and replace the placeholder:

```

```dart

2. Add your Google Gemini API key in `lib/config/api_keys.dart`static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

```

3. Run the app

```bashWith your actual API key:

flutter run

``````dart

static const String _apiKey = 'your-actual-api-key-here';

## 📦 Building for Production```



### Android APK### 3. Install Dependencies



```bash```bash

flutter cleanflutter pub get

flutter pub get```

flutter build apk --release

```### 4. Generate Code



Output: `build/app/outputs/flutter-apk/app-release.apk````bash

flutter pub run build_runner build --delete-conflicting-outputs

### Android App Bundle (Play Store)```



```bash### 5. Run the App

flutter build appbundle --release

``````bash

flutter run

Output: `build/app/outputs/bundle/release/app-release.aab````



## 🔐 Permissions## Project Structure



- **Microphone** - Audio recording```

- **Camera** (optional) - Photo attachmentslib/

- **Storage** - Saving audio/images├── main.dart                      # App entry point

- **Internet** - AI processing├── models/

│   ├── entry.dart                 # Entry data model

## 📱 Supported Platforms│   └── entry.g.dart               # Generated Hive adapter

├── services/

- ✅ Android 5.0+ (API 21+)│   ├── storage_service.dart       # Local storage with Hive

- ✅ iOS 12.0+│   ├── ai_service.dart           # Gemini AI integration

│   └── audio_recording_service.dart # Audio recording

## 🎨 Key Features├── providers/

│   └── app_providers.dart        # Riverpod state management

### Smart Categorization├── screens/

8 categories with auto-detection: Meeting, Idea, Todo, Journal, Reminder, Personal, Work, Note│   ├── home_screen.dart          # Main screen

│   ├── entry_detail_screen.dart  # Entry detail view

### Advanced Filtering│   ├── history_screen.dart       # All entries list

- Search by title/content/transcript│   └── settings_screen.dart      # App settings

- Filter by category or favorites└── widgets/

- Sort by date/duration/alphabetically    ├── recording_button.dart     # Hero recording button

- Pinned entries stay on top    ├── waveform_visualizer.dart  # Live audio waveform

    └── audio_player_widget.dart  # Audio playback controls

### Instant Updates```

All operations update immediately - no reload needed

## Key Technologies

## 📄 Version

- **Flutter** - Cross-platform framework

**1.0.0** (Build 1) - November 2, 2025- **Cupertino Widgets** - iOS-style UI components

- **Riverpod** - State management
- **Hive** - Fast, encrypted local database
- **Google Gemini AI** - Audio transcription and text polishing
- **record** - Audio recording
- **audioplayers** - Audio playback
- **flutter_markdown** - Markdown rendering

## Usage

### Recording

1. Tap the blue microphone button on the home screen
2. Speak your thoughts (up to 10 minutes)
3. The button turns red and shows a live waveform
4. Tap again to stop, or it auto-stops after 8 seconds of silence
5. AI processes your audio in the background

### Viewing Entries

- Recent entries appear on the home screen
- Tap any entry to view details
- See the polished note, raw transcript, and play audio
- Edit titles and notes by tapping the text

### History & Search

- Tap the list icon (top right) to see all entries
- Use the search bar to find specific entries
- Entries are grouped by date

### Settings

- Tap the gear icon (top right) for settings
- Configure recording preferences
- View storage usage
- Privacy information

## Design Philosophy

This app follows the **Apple Human Interface Guidelines** and **Jony Ive's Principle of Inevitability**:

- **Speed to capture** - < 1 second from unlock to recording
- **Invisible complexity** - AI processes in background
- **Respectful defaults** - Offline-first, private by default
- **System citizenship** - Feels native to the OS

## Privacy & Data

- ✅ Recordings stored locally on your device
- ✅ Audio sent to Google Gemini for processing
- ✅ Gemini does not store audio data
- ✅ Local database is encrypted
- ✅ No analytics or tracking
- ✅ No account required

## Permissions Required

- **Microphone** - To record audio
- **Storage** - To save recordings locally

## Roadmap

- [ ] Cloud sync with Firebase
- [ ] Export to multiple formats (PDF, TXT, MD)
- [ ] Custom AI prompts
- [ ] Voice shortcuts and Siri integration
- [ ] Apple Watch companion app
- [ ] Configurable silence detection
- [ ] Multiple AI model support
- [ ] Tags and categories

## Troubleshooting

### Recording doesn't start
- Check microphone permissions in system settings
- Ensure the app has permission to access the microphone

### Processing fails
- Verify your Gemini API key is correct
- Check your internet connection
- Ensure you haven't exceeded API quota

### Audio playback issues
- Verify the audio file exists
- Check device volume
- Try restarting the app

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Design inspired by Apple Voice Memos, Day One, and Things 3
- AI processing powered by Google Gemini
- Built with Flutter and love ❤️

---

**Version:** 1.0.0  
**Last Updated:** November 1, 2025
