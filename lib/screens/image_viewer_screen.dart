import 'package:flutter/cupertino.dart';
import 'dart:io';

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  const ImageViewerScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black.withValues(alpha: 0.8),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
