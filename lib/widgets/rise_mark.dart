import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Small brand mark used in headers across Stitch screens.
class RiseMark extends StatelessWidget {
  const RiseMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_twilight_rounded,
            color: AppColors.primaryContainer,
            size: size * 0.44,
          ),
          Text(
            'RISE',
            style: GoogleFonts.sora(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.primary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The hero crest emblem SVG from Stitch Welcome Screen.
class HeroCrestEmblem extends StatelessWidget {
  const HeroCrestEmblem({super.key, this.size = 144});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient soft glow behind crest
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.25),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _HeroCrestPainter(),
          ),
        ],
      ),
    );
  }
}

class _HeroCrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 160.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Outer circle (cx=80, cy=80, r=70)
    final outerPaint = Paint()
      ..color = AppColors.surfaceLow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(80, 80), 70, outerPaint);

    final outerStroke = Paint()
      ..color = const Color(0xFF303349)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(80, 80), 70, outerStroke);

    // 2. Sun disk (cx=80, cy=82, r=34)
    final sunFill = Paint()
      ..color = const Color(0xFFFF8A3D).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(80, 82), 34, sunFill);

    final sunStroke = Paint()
      ..color = const Color(0xFFFFB68D)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(80, 82), 34, sunStroke);

    // 3. Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFB68D)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(80, 32), const Offset(80, 42), rayPaint);
    canvas.drawLine(const Offset(45, 46), const Offset(52, 53), rayPaint);
    canvas.drawLine(const Offset(115, 46), const Offset(108, 53), rayPaint);

    // 4. Horizon line (x1=30, y1=82, x2=130, y2=82)
    final horizonPaint = Paint()
      ..color = const Color(0xFF564338)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(30, 82), const Offset(130, 82), horizonPaint);

    // 5. Road curve path: M28 82 C55 82 62 108 80 108 C98 108 105 82 132 82
    final roadPath = Path()
      ..moveTo(28, 82)
      ..cubicTo(55, 82, 62, 108, 80, 108)
      ..cubicTo(98, 108, 105, 82, 132, 82);
    final roadPaint = Paint()
      ..color = const Color(0xFFFFB68D)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(roadPath, roadPaint);

    // 6. Runner head (cx=82, cy=66, r=4.5)
    final headPaint = Paint()
      ..color = const Color(0xFFFFDBC9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(82, 66), 4.5, headPaint);

    // 7. Runner body path: M77 73 C80 71 85 71 88 74 L84 84 L91 93
    final bodyPath = Path()
      ..moveTo(77, 73)
      ..cubicTo(80, 71, 85, 71, 88, 74)
      ..lineTo(84, 84)
      ..lineTo(91, 93);
    final bodyPaint = Paint()
      ..color = const Color(0xFFFFDBC9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bodyPath, bodyPaint);

    // 8. Text "RISE" at (80, 132)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'RISE',
        style: GoogleFonts.sora(
          color: const Color(0xFFDFE0FD),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(80 - textPainter.width / 2, 132 - textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScreenEyebrow extends StatelessWidget {
  const ScreenEyebrow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.primary,
      ),
    );
  }
}

class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, this.color = AppColors.tertiary, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _anim.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _anim.value * 0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class WakeBadge extends StatelessWidget {
  const WakeBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(size: 7, color: AppColors.tertiary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.tertiaryFixed,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class RunnerAvatar extends StatelessWidget {
  const RunnerAvatar({super.key, this.size = 36, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceHigh,
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: ClipOval(
          child: Image.network(
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=160&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person_rounded,
              size: size * 0.55,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified Stitch header used on Home, Progress, Settings, and Celebration.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.eyebrow = '21-Day Habit',
    this.wakeLabel,
    this.leading,
    this.showAvatar = true,
  });

  final String title;
  final String eyebrow;
  final String? wakeLabel;
  final Widget? leading;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ] else ...[
            const RiseMark(size: 34),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ScreenEyebrow(text: eyebrow),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (wakeLabel != null) ...[
            WakeBadge(label: wakeLabel!),
            const SizedBox(width: 8),
          ],
          if (showAvatar) const RunnerAvatar(size: 34),
        ],
      ),
    );
  }
}
