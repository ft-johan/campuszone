import 'package:flutter/material.dart';

class SquigglyDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const SquigglyDivider({
    super.key,
    this.height = 20.0,
    this.width = double.infinity,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SquigglyLinePainter(color: color),
      ),
    );
  }
}

class _SquigglyLinePainter extends CustomPainter {
  final Color color;

  _SquigglyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double amplitude = 10; // Controls the wave height

    path.moveTo(0, size.height / 2);

    // Draw waves with quadratic Bézier curves (check out https://en.wikipedia.org/wiki/B%C3%A9zier_curve and cg isnt bad after all)
    for (double x = 0; x <= size.width; x += 20) {
      double controlX = x + 10; // ok
      double controlY = size.height / 2 +
          (x % 40 == 0 ? amplitude : -amplitude); // bruh idk dis
      double endX = x + 20;
      double endY = size.height / 2;

      path.quadraticBezierTo(controlX, controlY, endX, endY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
