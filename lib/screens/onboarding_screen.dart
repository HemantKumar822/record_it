import 'package:flutter/cupertino.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: CupertinoIcons.waveform,
      title: 'Voice to Notes',
      description: 'Simply tap and speak. Your voice is automatically transcribed with AI-powered accuracy.',
    ),
    OnboardingPage(
      icon: CupertinoIcons.sparkles,
      title: 'Smart Summary',
      description: 'Get polished, well-formatted notes with automatic grammar fixes and smart organization.',
    ),
    OnboardingPage(
      icon: CupertinoIcons.lock_shield,
      title: 'Private & Secure',
      description: 'Everything stays on your device. No cloud storage. Complete privacy and control.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onPressed: widget.onComplete,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Continue/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onComplete();
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Continue' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Terms
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          // Minimal animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Icon(
                    page.icon,
                    size: 90,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 56),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label.resolveFrom(context),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 17,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? CupertinoColors.systemBlue
            : CupertinoColors.systemGrey4.resolveFrom(context),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
