import 'dart:math' as math;
import 'package:flutter/material.dart';

enum Ico {
  tv,
  radio,
  webcam,
  heartFilled,
  heartOutline,
  search,
  settings,
  refresh,
  filter,
  sort,
  close,
  check,
  play,
  pause,
  prev,
  next,
  plus,
  minus,
  history,
  globe,
  language,
  category,
  sliders,
}

class TvIcon extends StatelessWidget {
  final Ico icon;
  final Color tint;
  final double size;

  const TvIcon(
    this.icon, {
    super.key,
    this.tint = Colors.white,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TvIconPainter(icon, tint),
      ),
    );
  }
}

class _TvIconPainter extends CustomPainter {
  final Ico icon;
  final Color tint;

  _TvIconPainter(this.icon, this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = 2.0;

    final stroke = Paint()
      ..color = tint
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = tint
      ..style = PaintingStyle.fill;

    Path tri(double x0, double x1, [bool flip = false]) {
      final p = Path();
      if (!flip) {
        p.moveTo(x0, 0);
        p.lineTo(x1, h / 2);
        p.lineTo(x0, h);
      } else {
        p.moveTo(x1, 0);
        p.lineTo(x0, h / 2);
        p.lineTo(x1, h);
      }
      p.close();
      return p;
    }

    switch (icon) {
      case Ico.tv:
        // Television screen
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.1, h * 0.18, w * 0.8, h * 0.58),
            const Radius.circular(4),
          ),
          stroke,
        );
        // Stand neck & base
        canvas.drawLine(Offset(w * 0.5, h * 0.76), Offset(w * 0.5, h * 0.90), stroke);
        canvas.drawLine(Offset(w * 0.32, h * 0.90), Offset(w * 0.68, h * 0.90), stroke);
        // Antennas
        canvas.drawLine(Offset(w * 0.44, h * 0.18), Offset(w * 0.28, h * 0.04), stroke);
        canvas.drawLine(Offset(w * 0.56, h * 0.18), Offset(w * 0.72, h * 0.04), stroke);
        break;

      case Ico.radio:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.84, h * 0.58),
            const Radius.circular(4),
          ),
          stroke,
        );
        canvas.drawCircle(Offset(w * 0.35, h * 0.57), w * 0.17, stroke);
        canvas.drawCircle(Offset(w * 0.35, h * 0.57), w * 0.05, fill);
        canvas.drawLine(Offset(w * 0.62, h * 0.46), Offset(w * 0.82, h * 0.46), stroke);
        canvas.drawLine(Offset(w * 0.62, h * 0.66), Offset(w * 0.82, h * 0.66), stroke);
        canvas.drawLine(Offset(w * 0.22, h * 0.28), Offset(w * 0.78, h * 0.06), stroke);
        break;

      case Ico.webcam:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.1, h * 0.24, w * 0.56, h * 0.52),
            const Radius.circular(4),
          ),
          stroke,
        );
        final lens = Path()
          ..moveTo(w * 0.66, h * 0.38)
          ..lineTo(w * 0.90, h * 0.24)
          ..lineTo(w * 0.90, h * 0.76)
          ..lineTo(w * 0.66, h * 0.62)
          ..close();
        canvas.drawPath(lens, fill);
        canvas.drawCircle(Offset(w * 0.38, h * 0.50), w * 0.12, stroke);
        break;

      case Ico.heartFilled:
        final p = Path()
          ..moveTo(w * 0.5, h * 0.86)
          ..cubicTo(w * 0.12, h * 0.56, 0, h * 0.34, 0, h * 0.20)
          ..cubicTo(0, h * 0.06, w * 0.16, 0, w * 0.34, 0)
          ..cubicTo(w * 0.44, 0, w * 0.5, h * 0.08, w * 0.5, h * 0.14)
          ..cubicTo(w * 0.5, h * 0.08, w * 0.56, 0, w * 0.66, 0)
          ..cubicTo(w * 0.84, 0, w, h * 0.06, w, h * 0.20)
          ..cubicTo(w, h * 0.34, w * 0.88, h * 0.56, w * 0.5, h * 0.86)
          ..close();
        canvas.drawPath(p, fill);
        break;

      case Ico.heartOutline:
        final p = Path()
          ..moveTo(w * 0.5, h * 0.86)
          ..cubicTo(w * 0.12, h * 0.56, 0, h * 0.34, 0, h * 0.20)
          ..cubicTo(0, h * 0.06, w * 0.16, 0, w * 0.34, 0)
          ..cubicTo(w * 0.44, 0, w * 0.5, h * 0.08, w * 0.5, h * 0.14)
          ..cubicTo(w * 0.5, h * 0.08, w * 0.56, 0, w * 0.66, 0)
          ..cubicTo(w * 0.84, 0, w, h * 0.06, w, h * 0.20)
          ..cubicTo(w, h * 0.34, w * 0.88, h * 0.56, w * 0.5, h * 0.86)
          ..close();
        canvas.drawPath(p, stroke);
        break;

      case Ico.search:
        canvas.drawCircle(Offset(w * 0.42, h * 0.42), w * 0.30, stroke);
        canvas.drawLine(
          Offset(w * 0.64, h * 0.64),
          Offset(w * 0.88, h * 0.88),
          stroke..strokeWidth = strokeWidth * 1.3,
        );
        break;

      case Ico.settings:
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.28, stroke);
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.12, stroke);
        final r1 = w * 0.30;
        final r2 = w * 0.44;
        for (int angle = 0; angle < 360; angle += 45) {
          final rad = angle * math.pi / 180;
          final c = math.cos(rad);
          final s = math.sin(rad);
          canvas.drawLine(
            Offset(w * 0.5 + r1 * c, h * 0.5 + r1 * s),
            Offset(w * 0.5 + r2 * c, h * 0.5 + r2 * s),
            stroke..strokeWidth = strokeWidth * 1.2,
          );
        }
        break;

      case Ico.refresh:
        canvas.drawArc(
          Rect.fromLTWH(w * 0.16, h * 0.16, w * 0.68, h * 0.68),
          45 * math.pi / 180,
          270 * math.pi / 180,
          false,
          stroke,
        );
        final arrow = Path()
          ..moveTo(w * 0.68, h * 0.04)
          ..lineTo(w * 0.84, h * 0.20)
          ..lineTo(w * 0.56, h * 0.20)
          ..close();
        canvas.drawPath(arrow, fill);
        break;

      case Ico.filter:
      case Ico.sliders:
        canvas.drawLine(Offset(w * 0.12, h * 0.26), Offset(w * 0.88, h * 0.26), stroke);
        canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.09, fill);

        canvas.drawLine(Offset(w * 0.12, h * 0.50), Offset(w * 0.88, h * 0.50), stroke);
        canvas.drawCircle(Offset(w * 0.68, h * 0.50), w * 0.09, fill);

        canvas.drawLine(Offset(w * 0.12, h * 0.74), Offset(w * 0.88, h * 0.74), stroke);
        canvas.drawCircle(Offset(w * 0.42, h * 0.74), w * 0.09, fill);
        break;

      case Ico.sort:
        canvas.drawLine(Offset(w * 0.32, h * 0.80), Offset(w * 0.32, h * 0.20), stroke);
        final up = Path()
          ..moveTo(w * 0.18, h * 0.34)
          ..lineTo(w * 0.32, h * 0.18)
          ..lineTo(w * 0.46, h * 0.34);
        canvas.drawPath(up, stroke);

        canvas.drawLine(Offset(w * 0.68, h * 0.20), Offset(w * 0.68, h * 0.80), stroke);
        final down = Path()
          ..moveTo(w * 0.54, h * 0.66)
          ..lineTo(w * 0.68, h * 0.82)
          ..lineTo(w * 0.82, h * 0.66);
        canvas.drawPath(down, stroke);
        break;

      case Ico.close:
        canvas.drawLine(Offset(w * 0.22, h * 0.22), Offset(w * 0.78, h * 0.78), stroke..strokeWidth = strokeWidth * 1.2);
        canvas.drawLine(Offset(w * 0.78, h * 0.22), Offset(w * 0.22, h * 0.78), stroke..strokeWidth = strokeWidth * 1.2);
        break;

      case Ico.check:
        final check = Path()
          ..moveTo(w * 0.18, h * 0.52)
          ..lineTo(w * 0.40, h * 0.74)
          ..lineTo(w * 0.82, h * 0.26);
        canvas.drawPath(check, stroke..strokeWidth = strokeWidth * 1.3);
        break;

      case Ico.play:
        canvas.drawPath(tri(w * 0.18, w * 0.90), fill);
        break;

      case Ico.pause:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.12, w * 0.24, h * 0.76), const Radius.circular(3)), fill);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.58, h * 0.12, w * 0.24, h * 0.76), const Radius.circular(3)), fill);
        break;

      case Ico.next:
        canvas.drawPath(tri(w * 0.1, w * 0.70), fill);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.76, h * 0.12, w * 0.14, h * 0.76), const Radius.circular(2)), fill);
        break;

      case Ico.prev:
        canvas.drawPath(tri(w * 0.30, w * 0.90, true), fill);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.10, h * 0.12, w * 0.14, h * 0.76), const Radius.circular(2)), fill);
        break;

      case Ico.plus:
        canvas.drawLine(Offset(w * 0.16, h * 0.5), Offset(w * 0.84, h * 0.5), stroke..strokeWidth = strokeWidth * 1.3);
        canvas.drawLine(Offset(w * 0.5, h * 0.16), Offset(w * 0.5, h * 0.84), stroke..strokeWidth = strokeWidth * 1.3);
        break;

      case Ico.minus:
        canvas.drawLine(Offset(w * 0.16, h * 0.5), Offset(w * 0.84, h * 0.5), stroke..strokeWidth = strokeWidth * 1.3);
        break;

      case Ico.history:
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, stroke);
        canvas.drawLine(Offset(w * 0.5, h * 0.5), Offset(w * 0.5, h * 0.26), stroke);
        canvas.drawLine(Offset(w * 0.5, h * 0.5), Offset(w * 0.68, h * 0.5), stroke);
        break;

      case Ico.globe:
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, stroke);
        canvas.drawLine(Offset(w * 0.12, h * 0.5), Offset(w * 0.88, h * 0.5), stroke);
        canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.44, height: h * 0.76), stroke);
        break;

      case Ico.language:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.16, w * 0.76, h * 0.56), const Radius.circular(4)), stroke);
        final tail = Path()
          ..moveTo(w * 0.28, h * 0.72)
          ..lineTo(w * 0.28, h * 0.90)
          ..lineTo(w * 0.44, h * 0.72)
          ..close();
        canvas.drawPath(tail, fill);
        canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.74, h * 0.36), stroke);
        canvas.drawLine(Offset(w * 0.26, h * 0.52), Offset(w * 0.60, h * 0.52), stroke);
        break;

      case Ico.category:
        final s = w * 0.32;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.12, s, s), const Radius.circular(2)), stroke);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.56, h * 0.12, s, s), const Radius.circular(2)), stroke);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.56, s, s), const Radius.circular(2)), stroke);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.56, h * 0.56, s, s), const Radius.circular(2)), stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _TvIconPainter oldDelegate) =>
      oldDelegate.icon != icon || oldDelegate.tint != tint;
}
