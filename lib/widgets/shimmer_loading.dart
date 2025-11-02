import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                math.max(0.0, _controller.value - 0.3),
                _controller.value,
                math.min(1.0, _controller.value + 0.3),
              ],
              colors: isDark
                  ? [
                      CupertinoColors.systemGrey6.darkColor,
                      CupertinoColors.systemGrey5.darkColor,
                      CupertinoColors.systemGrey6.darkColor,
                    ]
                  : [
                      CupertinoColors.systemGrey6.color,
                      CupertinoColors.systemGrey5.color,
                      CupertinoColors.systemGrey6.color,
                    ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerEntryCard extends StatelessWidget {
  const ShimmerEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).brightness == Brightness.dark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.systemGrey6.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerLoading(
                  width: 40,
                  height: 40,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 8),
                      ShimmerLoading(
                        width: 100,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ShimmerLoading(
              width: double.infinity,
              height: 12,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            ShimmerLoading(
              width: double.infinity,
              height: 12,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            ShimmerLoading(
              width: 200,
              height: 12,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
