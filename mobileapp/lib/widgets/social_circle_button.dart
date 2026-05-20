import 'package:flutter/material.dart';

const double _kButtonSize = 52.0;
const double _kIconSize = 22.0;

class SocialCircleButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const SocialCircleButton({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.onTap,
  });

  factory SocialCircleButton.google({VoidCallback? onTap}) =>
      SocialCircleButton(onTap: onTap, child: const _GoogleG());

  factory SocialCircleButton.facebook({VoidCallback? onTap}) =>
      SocialCircleButton(
        onTap: onTap,
        backgroundColor: const Color(0xFF1877F2),
        child: const _FacebookF(),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kButtonSize,
        height: _kButtonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: backgroundColor == Colors.white
              ? Border.all(color: const Color(0xFFE8E8F2), width: 1)
              : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kIconSize,
      height: _kIconSize,
      child: CustomPaint(painter: const _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.41;
    final sw = size.width * 0.20;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    // Clockwise from 3 o'clock, ~350 total, 10 gap at bar
    // Green:  5 to 65  (60 sweep)
    canvas.drawArc(rect, 0.087, 1.047, false, arc(_green));
    // Yellow: 65 to 125 (60 sweep)
    canvas.drawArc(rect, 1.134, 1.047, false, arc(_yellow));
    // Red:   125 to 215 (90 sweep)
    canvas.drawArc(rect, 2.182, 1.571, false, arc(_red));
    // Blue:  215 to 355 (140 sweep)
    canvas.drawArc(rect, 3.752, 2.443, false, arc(_blue));

    // Horizontal bar — blue, from center to right edge
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r + sw / 2, cy),
      Paint()
        ..color = _blue
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter old) => false;
}

class _FacebookF extends StatelessWidget {
  const _FacebookF();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kIconSize,
      height: _kIconSize,
      child: CustomPaint(painter: const _FacebookFPainter()),
    );
  }
}

class _FacebookFPainter extends CustomPainter {
  const _FacebookFPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sw = w * 0.18;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.square;

    // Vertical stroke
    final vx = w * 0.52;
    canvas.drawLine(Offset(vx, h * 0.12), Offset(vx, h * 0.88), paint);

    // Crossbar
    canvas.drawLine(
      Offset(w * 0.30, h * 0.50),
      Offset(w * 0.74, h * 0.50),
      paint,
    );

    // Top curve
    canvas.drawArc(
      Rect.fromLTWH(w * 0.22, h * 0.08, w * 0.60, h * 0.36),
      -3.14159,
      1.5708,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_FacebookFPainter old) => false;
}
