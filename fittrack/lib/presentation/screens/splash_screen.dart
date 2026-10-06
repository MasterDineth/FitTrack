import 'dart:math' as math;
import 'dart:ui' show FontFeature, ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/splash_provider.dart';

// ---------------------------------------------------------------------------
// FitTrack splash: "Progressive overload"
//
// Seven frosted pillars rise as an ascending staircase (one rep each), the
// stacked wordmark unmasks, the last pillar earns a PR badge, and a rep
// counter replaces any loading bar. When the intro is done AND auth has
// resolved, a curtain in the app's background colour wipes up and the splash
// flips [splashDoneProvider] so the router can move on.
//
// Timeline (seconds): floor 0-0.3, pillars 0.3-1.93, wordmark 1.2-2.0,
// PR pop 1.9-2.35, rep-complete beat 2.2-2.8. Hold = equalizer idle.
// Needs the 'Anton' font bundled as an asset (see pubspec notes).
// ---------------------------------------------------------------------------

const double _kIntroSeconds = 2.8;
const Color _kBg = Color(0xFF0A0716);
const Color _kBgStart = Color(0xFF05030C);
const Color _kViolet = Color(0xFF7C5CFA);
const Color _kMagenta = Color(0xFFFF4FA3);
const Color _kGold = Color(0xFFFFC857);
const double _kGap = 6;
const List<double> _kFractions = [0.18, 0.26, 0.34, 0.43, 0.52, 0.62, 0.74];
const List<Color> _kCaps = [
  Color(0xFF7C5CFA),
  Color(0xFF9B5CFA),
  Color(0xFFBC57F0),
  Color(0xFFDB52D0),
  Color(0xFFF24FB4),
  Color(0xFFFF6C8A),
  Color(0xFFFFB45A),
];
const Cubic _kRise = Cubic(0.2, 0.9, 0.25, 1.15); // ~4% overshoot

double _riseStart(int i) => 0.30 + 0.18 * i;

/// Progress (0..1, curved) of a segment that starts at [start] seconds and
/// lasts [dur] seconds, evaluated at time [s].
double _w(double s, double start, double dur, [Curve curve = Curves.linear]) {
  final x = ((s - start) / dur).clamp(0.0, 1.0).toDouble();
  return curve.transform(x);
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _idle;
  late final AnimationController _exit;

  final List<bool> _haptic = List<bool>.filled(8, false);
  bool _started = false;
  bool _reduce = false;
  bool _introDone = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )
      ..addListener(_onTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _introDone = true);
          _idle.repeat();
          _maybeExit();
        }
      });
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduce = MediaQuery.disableAnimationsOf(context);
    if (_reduce) {
      // Reduced motion: show the settled frame, then hand off after 200 ms.
      _intro.value = 1;
      _introDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeExit());
    } else {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _idle.dispose();
    _exit.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_reduce) return;
    final s = _intro.value * _kIntroSeconds;
    for (var i = 0; i < 7; i++) {
      if (!_haptic[i] && s >= _riseStart(i) + 0.25) {
        _haptic[i] = true;
        HapticFeedback.selectionClick();
      }
    }
    if (!_haptic[7] && s >= 1.95) {
      _haptic[7] = true;
      HapticFeedback.mediumImpact();
    }
  }

  void _maybeExit() {
    if (!mounted || _exiting || !_introDone) return;
    if (ref.read(authProvider).isLoading) return;
    _exiting = true;
    if (_reduce) {
      Future<void>.delayed(const Duration(milliseconds: 200), _finish);
    } else {
      _exit.forward().whenComplete(_finish);
    }
  }

  void _finish() {
    if (mounted) ref.read(splashDoneProvider.notifier).finish();
  }

  @override
  Widget build(BuildContext context) {
    // When auth resolves after the intro, start the exit.
    ref.listen(authProvider, (_, _) => _maybeExit());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Semantics(
          label: 'FitTrack is loading',
          child: LayoutBuilder(
            builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              return AnimatedBuilder(
                animation: Listenable.merge([_intro, _idle, _exit]),
                builder: (context, _) => _frame(context, size),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, Size size) {
    final s = _intro.value * _kIntroSeconds;
    final idle = _introDone ? _idle.value : 0.0;
    final exitT = _exit.value;
    final fx = _w(exitT, 0, 0.85, Curves.easeOut);
    final g = _Geo(size);
    final pad = MediaQuery.paddingOf(context).top;

    var count = 0.0;
    for (var i = 0; i < 7; i++) {
      count += _w(s, _riseStart(i), 0.14, Curves.easeOut);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _BackgroundPainter(s: s, g: g)),
        CustomPaint(
          painter: _PillarsPainter(s: s, idle: idle, done: _introDone, g: g),
        ),
        CustomPaint(painter: _BurstPainter(s: s, g: g)),
        Positioned(
          left: 24,
          top: pad + 52,
          child: _fx(fx, _overline(s)),
        ),
        Positioned(
          left: 24,
          top: pad + 68,
          child: _fx(fx, _wordmark(s)),
        ),
        Positioned(
          left: 24,
          top: pad + 232,
          child: _fx(fx, _tagline(s)),
        ),
        Positioned(
          right: 24,
          top: pad + 46,
          child: _fx(fx, _counter(s, count)),
        ),
        _prBadge(g, s, idle, fx),
        if (exitT > 0)
          CustomPaint(
            painter: _CurtainPainter(
              progress: Curves.easeInOutCubic.transform(_w(exitT, 0.08, 0.92)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
      ],
    );
  }

  // Exit effect for text: blur, lift 12 px and fade.
  Widget _fx(double e, Widget child) {
    if (e <= 0) return child;
    return Opacity(
      opacity: (1 - e).clamp(0.0, 1.0).toDouble(),
      child: Transform.translate(
        offset: Offset(0, -12 * e),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6 * e, sigmaY: 6 * e),
          child: child,
        ),
      ),
    );
  }

  Widget _overline(double s) {
    return Opacity(
      opacity: _w(s, 0.3, 0.4, Curves.easeOut),
      child: Text(
        'TRAINING, LOGGED',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _wordmark(double s) {
    const fontSize = 84.0;

    Widget line(String text, double start, {required bool gradient}) {
      final p = _w(s, start, 0.5, Curves.easeOutExpo);
      Widget t = Text(
        text,
        style: TextStyle(
          fontFamily: 'Anton',
          fontSize: fontSize,
          height: 0.9,
          letterSpacing: lerpDouble(fontSize * 0.12, -1, p),
          color: Colors.white,
        ),
      );
      if (gradient) {
        t = ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFC9B8FF)],
          ).createShader(r),
          child: t,
        );
      }
      return ClipRect(clipper: _RevealClipper(p), child: t);
    }

    Widget block = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        line('FIT', 1.20, gradient: false),
        line('TRACK', 1.32, gradient: true),
      ],
    );

    // One diagonal light streak through the letters, 1.4-2.0 s.
    if (s > 1.4 && s < 2.0) {
      final u = _w(s, 1.4, 0.6, Curves.easeInOut);
      block = ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideGradient(lerpDouble(-1.2, 1.2, u)!),
        ).createShader(r),
        child: block,
      );
    }
    return block;
  }

  Widget _tagline(double s) {
    final p = _w(s, 1.90, 0.30, Curves.easeOut);
    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, (1 - p) * 8),
        child: Text(
          'Progress, one rep at a time.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }

  Widget _counter(double s, double count) {
    const tabular = [FontFeature.tabularFigures()];
    final label = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: Colors.white.withValues(alpha: 0.6),
    );
    final number = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      height: 1.3,
      fontFeatures: tabular,
      color: Colors.white.withValues(alpha: 0.85),
    );
    return Opacity(
      opacity: _w(s, 0.3, 0.3, Curves.easeOut),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('REP ', style: label),
              _Odometer(value: count, style: number),
              Text('/07', style: number.copyWith(height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prBadge(_Geo g, double s, double idle, double fx) {
    final p = _w(s, 1.90, 0.45);
    if (p <= 0) return const SizedBox.shrink();
    final scale = p < 0.6
        ? 1.15 * Curves.easeOut.transform(p / 0.6)
        : 1.15 - 0.15 * Curves.easeInOut.transform((p - 0.6) / 0.4);
    final tilt = _introDone ? 0.105 * math.sin(2 * math.pi * idle) : 0.0;
    final c = g.badgeCenter;

    return Positioned(
      left: c.dx - 30,
      top: c.dy - 14,
      width: 60,
      height: 28,
      child: _fx(
        fx,
        Transform.rotate(
          angle: tilt,
          child: Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _kGold,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withValues(alpha: 0.45),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, size: 14, color: _kBg),
                  SizedBox(width: 3),
                  Text(
                    'PR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _kBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Geometry shared by the painters
// ---------------------------------------------------------------------------

class _Geo {
  _Geo(this.size) : pw = (size.width - _kGap * 6) / 7;

  final Size size;
  final double pw;

  double x(int i) => i * (pw + _kGap);
  double cx(int i) => x(i) + pw / 2;
  double top(int i) => size.height * (1 - _kFractions[i]);

  /// Badge sits 14 px above the tallest pillar, kept inside the screen.
  Offset get badgeCenter =>
      Offset(math.min(cx(6), size.width - 38), top(6) - 28);
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

void _glow(Canvas canvas, Offset c, double r, Color color, double alpha) {
  if (alpha <= 0) return;
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: r)),
  );
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.s, required this.g});

  final double s;
  final _Geo g;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Color.lerp(_kBgStart, _kBg, _w(s, 0, 0.3, Curves.easeOut))!;
    canvas.drawRect(rect, Paint()..color = base);

    final fade = _w(s, 0.1, 0.6, Curves.easeOut);
    _glow(canvas, Offset(size.width * 0.05, size.height), size.width * 0.95,
        _kViolet, 0.30 * fade);

    // Magenta heat that follows the tallest pillar as it rises.
    final heat = _w(s, _riseStart(6), 0.55, Curves.easeOut);
    _glow(canvas, Offset(g.cx(6), g.top(6)), size.width * 0.6, _kMagenta,
        0.22 * heat);

    // Floor line, visible only before the pillars cover it.
    final floor = 1 - _w(s, 0.9, 0.3);
    if (floor > 0) {
      final pulse = 0.6 + 0.4 * math.sin(s * 12);
      canvas.drawLine(
        Offset(0, size.height - 1),
        Offset(size.width, size.height - 1),
        Paint()
          ..strokeWidth = 1.5
          ..color = _kViolet.withValues(alpha: 0.6 * pulse * floor),
      );
    }

    // Vignette.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 1.1,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
          ],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => true;
}

class _PillarsPainter extends CustomPainter {
  _PillarsPainter({
    required this.s,
    required this.idle,
    required this.done,
    required this.g,
  });

  final double s;
  final double idle;
  final bool done;
  final _Geo g;

  @override
  void paint(Canvas canvas, Size size) {
    // "Rep complete" beat: pillars compress 2 px and release, 2.2-2.5 s.
    final beat = (s >= 2.2 && s < 2.5)
        ? 2.0 * math.sin(math.pi * (s - 2.2) / 0.3)
        : 0.0;

    for (var i = 0; i < 7; i++) {
      final rise = _w(s, _riseStart(i), 0.55, _kRise);
      var frac = _kFractions[i] * rise;
      if (done) frac *= 1 + 0.015 * math.sin(2 * math.pi * (idle - i * 0.12));
      if (frac <= 0.001) continue;

      final top = size.height - size.height * frac + beat;
      final x = g.x(i);
      final rr = RRect.fromLTRBAndCorners(
        x,
        top,
        x + g.pw,
        size.height + 2,
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
      );

      // Glass body.
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.04),
            ],
          ).createShader(rr.outerRect),
      );

      // Charge fill rising inside the pillar.
      final charge = _w(s, _riseStart(i) + 0.12, 0.55, Curves.easeOutCubic);
      if (charge > 0) {
        final cap = _kCaps[i];
        final chargeTop = size.height - (size.height - top) * charge;
        final cr = Rect.fromLTRB(x, chargeTop, x + g.pw, size.height + 2);
        canvas.save();
        canvas.clipRRect(rr);
        canvas.drawRect(
          cr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                _kCaps[0].withValues(alpha: 0.55),
                cap.withValues(alpha: 0.92),
              ],
            ).createShader(cr),
        );

        final shimmer =
            done ? 0.7 + 0.3 * math.sin(2 * math.pi * (idle * 2 - i * 0.1)) : 0.7;
        final capRect = Rect.fromLTWH(x, chargeTop, g.pw, 3);
        canvas.drawRect(
          capRect.inflate(2),
          Paint()
            ..color = cap.withValues(alpha: 0.8)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawRect(
          capRect,
          Paint()..color = Colors.white.withValues(alpha: shimmer),
        );
        canvas.restore();
      }

      // Pillar 7 flashes when the PR lands.
      if (i == 6) {
        final flash = s >= 1.9 ? 1 - _w(s, 1.9, 0.3) : 0.0;
        if (flash > 0) {
          canvas.drawRRect(
            rr,
            Paint()..color = Colors.white.withValues(alpha: 0.35 * flash),
          );
        }
      }

      // Glass edge: bright at the top, faint at the bottom.
      canvas.drawRRect(
        rr.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0.05),
            ],
          ).createShader(rr.outerRect),
      );
    }

    // A bright dot runs along the tops of the staircase, 2.3-2.8 s.
    if (s >= 2.3 && s <= 2.8) {
      final u = _w(s, 2.3, 0.5, Curves.easeInOut) * 6;
      final seg = u.floor().clamp(0, 5).toInt();
      final f = u - seg;
      final a = Offset(g.cx(seg), g.top(seg));
      final b = Offset(g.cx(seg + 1), g.top(seg + 1));
      final p = Offset.lerp(a, b, f)!;
      canvas.drawCircle(
        p,
        9,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_PillarsPainter old) => true;
}

/// Gold particles and three spark rays when the PR badge pops.
class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.s, required this.g});

  final double s;
  final _Geo g;

  @override
  void paint(Canvas canvas, Size size) {
    final tau = s - 1.95;
    if (tau < 0 || tau > 0.7) return;
    final origin = g.badgeCenter;

    const life = 0.6;
    for (var i = 0; i < 12; i++) {
      if (tau > life) break;
      final angle = i / 12 * 2 * math.pi + (i.isOdd ? 0.2 : 0.0);
      final speed = 70.0 + (i % 3) * 25;
      final pos = origin +
          Offset(
            math.cos(angle) * speed * tau,
            math.sin(angle) * speed * tau + 0.5 * 260 * tau * tau,
          );
      canvas.drawCircle(
        pos,
        2.4,
        Paint()..color = _kGold.withValues(alpha: 1 - tau / life),
      );
    }

    if (tau < 0.35) {
      final k = Curves.easeOut.transform(tau / 0.35);
      final paint = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = _kGold.withValues(alpha: 1 - tau / 0.35);
      for (final deg in const [-90.0, -30.0, -150.0]) {
        final r = deg * math.pi / 180;
        final dir = Offset(math.cos(r), math.sin(r));
        canvas.drawLine(
          origin + dir * (22 + 4 * k),
          origin + dir * (22 + 26 * k),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}

/// Curtain in the next screen's background colour, wiping up with a feathered
/// edge so the hand-off has no visible flash.
class _CurtainPainter extends CustomPainter {
  _CurtainPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const feather = 80.0;
    final frontTop = size.height - progress * (size.height + feather);

    final featherRect = Rect.fromLTWH(0, frontTop, size.width, feather);
    canvas.drawRect(
      featherRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0), color],
        ).createShader(featherRect),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, frontTop + feather, size.width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CurtainPainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _RevealClipper extends CustomClipper<Rect> {
  _RevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * progress, size.height);

  @override
  bool shouldReclip(_RevealClipper old) => old.progress != progress;
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * dx, 0, 0);
}

/// Two-digit rolling counter. [value] is continuous (0..7); the fractional
/// part slides the next number up like an odometer.
class _Odometer extends StatelessWidget {
  const _Odometer({required this.value, required this.style});

  final double value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 13;
    final h = fontSize * (style.height ?? 1.3);
    final base = value.floor().clamp(0, 7).toInt();
    final frac = value - value.floor();
    String two(int n) => n.toString().padLeft(2, '0');

    return SizedBox(
      width: fontSize * 1.25,
      height: h,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: -frac * h,
              child: Text(two(base), style: style),
            ),
            if (base < 7)
              Positioned(
                left: 0,
                top: h - frac * h,
                child: Text(two(base + 1), style: style),
              ),
          ],
        ),
      ),
    );
  }
}
