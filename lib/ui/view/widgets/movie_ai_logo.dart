import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Logo do MovieAI: uma tela com o botão de play e três pontos acima.
///
/// Desenhado em código a partir do SVG do Stitch (design/stitch/04_logo.svg),
/// para não precisar de um pacote de SVG.
class MovieAiLogo extends StatelessWidget {
  const MovieAiLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MovieAI',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // O SVG original usa um viewBox de 100 × 100.
    canvas.scale(size.width / 100, size.height / 100);
    final shader = AppColors.brandGradient.createShader(
      const Rect.fromLTWH(0, 0, 100, 100),
    );

    final screen = RRect.fromRectAndRadius(
      const Rect.fromLTWH(14, 24, 72, 52),
      const Radius.circular(14),
    );
    canvas.drawRRect(screen, Paint()..color = const Color(0xFF181B22));
    canvas.drawRRect(
      screen,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final play = Path()
      ..moveTo(42, 38)
      ..lineTo(66, 50)
      ..lineTo(42, 62)
      ..close();
    canvas.drawPath(play, Paint()..shader = shader);

    canvas.drawCircle(
      const Offset(28, 18),
      4,
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawCircle(
      const Offset(50, 15),
      3.5,
      Paint()..color = const Color(0xFFEC4899),
    );
    canvas.drawCircle(
      const Offset(72, 18),
      4,
      Paint()..color = const Color(0xFF8B5CF6),
    );

    final spark = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(78, 28), const Offset(85, 21), spark);
    canvas.drawLine(const Offset(82, 35), const Offset(90, 32), spark);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
