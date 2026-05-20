import 'package:flutter/material.dart';

class InwardHeaderClipper extends CustomClipper<Path> {
  final double curveDepth;
  const InwardHeaderClipper({this.curveDepth = 36});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - curveDepth,
      0,
      size.height,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(InwardHeaderClipper oldClipper) =>
      oldClipper.curveDepth != curveDepth;
}

class AuthWavePainter extends CustomPainter {
  final Color color;
  const AuthWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final cx = size.width * 0.85;
    final cy = size.height * 0.3;
    for (double r = 40; r <= 120; r += 28) {
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(AuthWavePainter oldDelegate) => false;
}
