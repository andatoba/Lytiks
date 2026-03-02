import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: AgronomyLoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class AgronomyLoginPage extends StatefulWidget {
  const AgronomyLoginPage({super.key});

  @override
  State<AgronomyLoginPage> createState() => _AgronomyLoginPageState();
}

class _AgronomyLoginPageState extends State<AgronomyLoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackground(),
          // Noise overlay (muy sutil, da “premium texture”)
          IgnorePointer(
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(
                size: Size.infinite,
                painter: _NoisePainter(),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ScaleTransition(
                          scale: _scale,
                          child: _GlassShell(
                            child: Flex(
                              direction: isMobile ? Axis.vertical : Axis.horizontal,
                              children: [
                                Expanded(
                                  flex: isMobile ? 0 : 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(36),
                                    child: _LeftLogin(
                                      emailCtrl: _emailCtrl,
                                      passCtrl: _passCtrl,
                                      isMobile: isMobile,
                                    ),
                                  ),
                                ),
                                if (!isMobile)
                                  Expanded(
                                    flex: 6,
                                    child: _RightShowcase(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftLogin extends StatefulWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool isMobile;

  const _LeftLogin({
    required this.emailCtrl,
    required this.passCtrl,
    required this.isMobile,
  });

  @override
  State<_LeftLogin> createState() => _LeftLoginState();
}

class _LeftLoginState extends State<_LeftLogin> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // “Logo” moderno (icono + glow)
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5CFF87), Color(0xFF2BE7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2BE7FF).withOpacity(0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AgroAnalytics",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  "AI agronómica para decisiones rápidas",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 28),

        const Text(
          "Inicia sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Accede a pronósticos, clima y monitoreo satelital en una sola vista.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 14,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 26),

        _GlowField(
          label: "Email",
          hint: "usuario@agrotech.com",
          icon: Icons.alternate_email_rounded,
          controller: widget.emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        _GlowField(
          label: "Contraseña",
          hint: "••••••••",
          icon: Icons.lock_outline_rounded,
          controller: widget.passCtrl,
          obscureText: _hide,
          suffix: IconButton(
            onPressed: () => setState(() => _hide = !_hide),
            icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded),
            color: Colors.white60,
          ),
        ),

        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              "¿Olvidaste tu contraseña?",
              style: TextStyle(color: Color(0xFF8BFFC1)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        _PrimaryNeonButton(
          text: "Continuar",
          onPressed: () {},
        ),

        const SizedBox(height: 18),

        // Divider “premium”
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text("o", style: TextStyle(color: Colors.white.withOpacity(0.55))),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
          ],
        ),

        const SizedBox(height: 16),

        // Social / SSO placeholders (modern UX)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _GhostButton(
              icon: Icons.g_mobiledata_rounded,
              text: "Google",
              onPressed: () {},
            ),
            _GhostButton(
              icon: Icons.business_rounded,
              text: "SSO",
              onPressed: () {},
            ),
          ],
        ),

        const SizedBox(height: 18),

        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text("¿Nuevo aquí? ", style: TextStyle(color: Colors.white60)),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Solicitar demo",
                  style: TextStyle(color: Color(0xFF8BFFC1), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        if (widget.isMobile) ...[
          const SizedBox(height: 18),
          Text(
            "Tip: habilita geolocalización para alertas de riesgo y clima hiper-local.",
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _RightShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Inteligencia agronómica\ncon estética de producto premium",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Monitorea salud del cultivo, clima y riesgo fitosanitario con señales claras.\nMenos fricción, más decisión.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _FeaturePill(
                icon: Icons.psychology_rounded,
                title: "IA Predictiva",
                desc: "Alertas tempranas de rendimiento y eventos críticos.",
                accent: Color(0xFF2BE7FF),
              ),
              _FeaturePill(
                icon: Icons.wb_sunny_rounded,
                title: "Clima Hiper-local",
                desc: "Satélite + estaciones para decisiones diarias.",
                accent: Color(0xFFFFC857),
              ),
              _FeaturePill(
                icon: Icons.layers_rounded,
                title: "Índices de Vegetación",
                desc: "NDVI / NDRE con lectura ejecutiva.",
                accent: Color(0xFFB18CFF),
              ),
              _FeaturePill(
                icon: Icons.science_rounded,
                title: "Suelo & Foliar",
                desc: "Nutrición variable basada en datos.",
                accent: Color(0xFF5CFF87),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _MiniStatsCard(),
        ],
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  final Widget child;
  const _GlassShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlowField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _GlowField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  State<_GlowField> createState() => _GlowFieldState();
}

class _GlowFieldState extends State<_GlowField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final glow = _focused ? 0.22 : 0.08;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.70),
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2BE7FF).withOpacity(glow),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.28)),
                prefixIcon: Icon(widget.icon, color: Colors.white60),
                suffixIcon: widget.suffix,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2BE7FF), width: 1.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryNeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PrimaryNeonButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF5CFF87), Color(0xFF2BE7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2BE7FF).withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _GhostButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: 160,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70),
        label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.14)),
          backgroundColor: Colors.white.withOpacity(0.04),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color accent;

  const _FeaturePill({
    required this.icon,
    required this.title,
    required this.desc,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accent.withOpacity(0.16),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    )),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatsCard extends StatelessWidget {
  const _MiniStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          _stat("Cobertura", "Satélite + estación"),
          const SizedBox(width: 14),
          _stat("Alertas", "Riesgo / clima"),
          const SizedBox(width: 14),
          _stat("Índices", "NDVI / NDRE"),
        ],
      ),
    );
  }

  Widget _stat(String k, String v) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _AuroraBackground extends StatefulWidget {
  const _AuroraBackground();

  @override
  State<_AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<_AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (, _) {
        final t = _c.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF070A12),
                Color(0xFF0B1326),
                Color(0xFF061018),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: _OrbsPainter(t: t),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double t;
  _OrbsPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;

    void orb(Offset c, double r, Color color) {
      paint.shader = RadialGradient(
        colors: [color.withOpacity(0.35), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }

    final w = size.width;
    final h = size.height;

    orb(Offset(w * (0.22 + 0.05 * sin(t * 2 * pi)), h * (0.28 + 0.06 * cos(t * 2 * pi))),
        min(w, h) * 0.55, const Color(0xFF2BE7FF));

    orb(Offset(w * (0.78 + 0.06 * cos(t * 2 * pi)), h * (0.30 + 0.05 * sin(t * 2 * pi))),
        min(w, h) * 0.48, const Color(0xFF5CFF87));

    orb(Offset(w * (0.55 + 0.04 * sin(t * 2 * pi)), h * (0.78 + 0.05 * cos(t * 2 * pi))),
        min(w, h) * 0.60, const Color(0xFFB18CFF));
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) => oldDelegate.t != t;
}

class _NoisePainter extends CustomPainter {
  final _rand = Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    // Ruido rápido (puntitos)
    for (int i = 0; i < 12000; i++) {
      final dx = _rand.nextDouble() * size.width;
      final dy = _rand.nextDouble() * size.height;
      paint.color = Colors.white.withOpacity(_rand.nextDouble() * 0.10);
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}