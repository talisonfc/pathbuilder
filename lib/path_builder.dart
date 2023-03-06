import 'dart:math';

import 'package:flutter/material.dart';

class PathBuilder extends StatefulWidget {
  const PathBuilder({Key? key}) : super(key: key);

  @override
  State<PathBuilder> createState() => PathBuilderState();
}

class PathBuilderState extends State<PathBuilder> {
  final List<Offset> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Path Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                points.clear();
              });
            },
          )
        ],
      ),
      body: GestureDetector(
        onTapDown: (event) {
          // print(event.localPosition);
          setState(() {
            points.add(event.localPosition);
          });
        },
        child: CustomPaint(
            painter: PathPainter(points: points), child: Container()),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> points;

  PathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (points.isNotEmpty) {
      for (var i = 0; i < points.length; i++) {
        canvas.drawCircle(points[i], 2, paint);
      }
    }

    if (points.length >= 3) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) {
        // path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);

      for (var j = 0; j < (points.length - 2); j = j + 2) {
        final j1 = j;
        final j2 = j + 1;
        final j3 = j + 2;
        final p1 = points[j1];
        final p2 = points[j2];
        final p3 = points[j3];
        final center = centerThreePoints(p1, p2, p3);
        canvas.drawCircle(center, 2, paint);
        final radius = distTwoPoints(center, points[j1]);
        // canvas.drawCircle(center, radius, paint);

        final dy1 = points[j1].dy - center.dy;
        final dx1 = points[j1].dx - center.dx;
        double startAngle = asin((points[j1].dy - center.dy) / radius);
        if (dx1 < 0) {
          startAngle = pi - startAngle;
        } else if (dy1 < 0) {
          startAngle = 2 * pi + startAngle;
        }

        final dy2 = points[j3].dy - center.dy;
        final dx2 = points[j3].dx - center.dx;
        double sweepAngle = asin((points[j3].dy - center.dy) / radius);
        if (dx2 < 0) {
          sweepAngle = pi - sweepAngle;
        } else if (dy2 < 0) {
          sweepAngle = 2 * pi + sweepAngle;
        }
        // print('startAngle: $startAngle, sweepAngle: $sweepAngle');
        if ((sweepAngle - startAngle) < 0) {
          sweepAngle = (2 * pi - startAngle) + sweepAngle;
        } else {
          sweepAngle = sweepAngle - startAngle;
        }

        canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
            startAngle, sweepAngle, false, paint..color = Colors.red);

        final m13 = coefAng(p1, p3);
        final b13 = coefLinear(p1, p3);
        final y13 = m13 * p2.dx + b13;
        print('${y13 - p2.dy}');
      }
    }

    // final rect = Rect.fromPoints(Offset(100,100), Offset(200,200));
    // canvas.drawArc(rect, 0, pi/2, false, paint);
  }

  double coefAng(Offset p1, Offset p2) {
    return (p2.dy - p1.dy) / (p2.dx - p1.dx);
  }

  double coefLinear(Offset p1, Offset p2) {
    return p1.dy - coefAng(p1, p2) * p1.dx;
  }

  Offset centerThreePoints(Offset p1, Offset p2, Offset p3) {
    final m1 = coefAng(p1, p2);
    final m2 = coefAng(p2, p3);
    final pm1 = mediumPoint(p1, p2);
    final pm2 = mediumPoint(p2, p3);

    final mri1 = -1 / m1;
    final mri2 = -1 / m2;
    final bri1 = pm1.dy - mri1 * pm1.dx;
    final bri2 = pm2.dy - mri2 * pm2.dx;

    final x = (bri2 - bri1) / (mri1 - mri2);
    final y = mri1 * x + bri1;
    return Offset(x, y);
  }

  double distTwoPoints(Offset p1, Offset p2) {
    return sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
  }

  Offset mediumPoint(Offset p1, Offset p2) {
    return Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
