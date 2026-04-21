import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Premium splash screen for the Pulse sports app.
///
/// Sequence:
/// 1. "PULSE" logo scales up with a glowing backdrop.
/// 2. Continuous heartbeat / pulse micro-animation loops.
/// 3. Tagline fades in beneath the logo.
/// 4. After ~2.8 s the app auto-navigates to the auth screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────────────

  /// Drives the initial scale-up entrance (0 → 1).
  late final AnimationController _entranceController;

  /// Drives the continuous pulse / heartbeat micro-animation.
  late final AnimationController _pulseController;

  /// Controls the tagline fade-in.
  late final AnimationController _taglineController;

  // ── Animations ──────────────────────────────────────────────────────

  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceOpacity;
  late final Animation<double> _pulseScale;
  late final Animation<double> _taglineOpacity;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // ── Entrance: scale 0.3 → 1.0 over 900 ms, ease-out-back ─────
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entranceScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    // ── Heartbeat: 1.0 → 1.06 → 1.0 repeating ────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // infinite loop
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // ── Tagline: fades in 600 ms after entrance finishes ──────────
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    // Kick off the sequence.
    _entranceController.forward().then((_) {
      _taglineController.forward();
    });

    // Auto-navigate after 2.8 seconds.
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go('/auth');
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // ── Glow backdrop ──────────────────────────────────────
            AnimatedBuilder(
              animation: _entranceOpacity,
              builder: (context, _) {
                return AnimatedBuilder(
                  animation: Listenable.merge([_entranceOpacity, _pulseScale]),
                  builder: (context, _) {
                    return Container(
                      width: 260 * _pulseScale.value,
                      height: 260 * _pulseScale.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.footballAccent
                                .withValues(alpha: 0.25 * _entranceOpacity.value),
                            AppColors.footballAccent
                                .withValues(alpha: 0.08 * _entranceOpacity.value),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // ── "PULSE" logo text ──────────────────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([_entranceScale, _pulseScale]),
              builder: (context, _) {
                final scale = _entranceScale.value * _pulseScale.value;
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: _entranceOpacity.value,
                    child: _buildLogoText(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Tagline ────────────────────────────────────────────
            AnimatedBuilder(
              animation: _taglineOpacity,
              builder: (context, _) {
                return Opacity(
                  opacity: _taglineOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - _taglineOpacity.value)),
                    child: Text(
                      'Every Score. Every Sport. Live.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(flex: 3),

            // ── Subtle bottom version / branding ───────────────────
            AnimatedBuilder(
              animation: _taglineOpacity,
              builder: (context, _) {
                return Opacity(
                  opacity: _taglineOpacity.value * 0.5,
                  child: Text(
                    'v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds the "PULSE" logo text with a gradient fill and optional
  /// heartbeat icon above it.
  Widget _buildLogoText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heartbeat line icon
        CustomPaint(
          size: const Size(40, 24),
          painter: _HeartbeatPainter(
            color: AppColors.footballAccent,
            progress: _entranceOpacity.value,
          ),
        ),
        const SizedBox(height: 12),

        // Gradient text
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                AppColors.footballAccent,
                Color(0xFF06B6D4), // teal-400
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'PULSE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: Colors.white, // tinted by the shader
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom painter: animated heartbeat line ────────────────────────────

class _HeartbeatPainter extends CustomPainter {
  _HeartbeatPainter({required this.color, required this.progress});
  final Color color;
  final double progress; // 0 → 1

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.2, h * 0.5);
    path.lineTo(w * 0.28, h * 0.15);
    path.lineTo(w * 0.36, h * 0.85);
    path.lineTo(w * 0.44, h * 0.3);
    path.lineTo(w * 0.52, h * 0.5);
    path.lineTo(w * 0.7, h * 0.5);
    path.lineTo(w * 0.78, h * 0.2);
    path.lineTo(w * 0.86, h * 0.8);
    path.lineTo(w * 0.92, h * 0.45);
    path.lineTo(w, h * 0.5);

    // Clip the drawing progress for an animated reveal.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w * progress, h));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter old) =>
      old.progress != progress || old.color != color;
}
