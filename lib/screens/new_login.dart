import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';
import '../services/location_tracking_service.dart';
import 'cliente_home_screen.dart';
import 'home_screen.dart';

class NewLoginScreen extends StatefulWidget {
  const NewLoginScreen({super.key});

  @override
  State<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends State<NewLoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isClientLogin = false;

  static const String _clientPassword = '12345';

  final _authService = AuthService();
  final _locationTrackingService = LocationTrackingService();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _usernameController.addListener(_handleUsernameChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.removeListener(_handleUsernameChange);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF2BE7FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUsernameChange() {
    final next = _looksLikeEmail(_usernameController.text.trim());
    if (next == _isClientLogin) {
      return;
    }
    setState(() {
      _isClientLogin = next;
      if (_isClientLogin) {
        _passwordController.clear();
      }
    });
  }

  bool _looksLikeEmail(String value) {
    return value.contains('@');
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _isClientLogin ? _clientPassword : _passwordController.text;

    if (username.isEmpty) {
      _showMessage(
        _isClientLogin ? 'Por favor ingresa tu correo' : 'Por favor ingresa tu usuario',
      );
      return;
    }
    if (_isClientLogin) {
      if (!username.contains('@')) {
        _showMessage('Ingresa un correo valido');
        return;
      }
    } else {
      if (password.isEmpty) {
        _showMessage('Por favor ingresa tu contraseña');
        return;
      }
      if (password.length < 6) {
        _showMessage('La contraseña debe tener al menos 6 caracteres');
        return;
      }
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final loginResponse = await _authService.login(username, password);
      if (!mounted) return;

      final rawUser = loginResponse['user'];
      final user =
          rawUser is Map ? Map<String, dynamic>.from(rawUser) : <String, dynamic>{};

      final userRole =
          (user['rol'] ?? user['role'])?.toString().toUpperCase() ?? '';
      final userId = user['id']?.toString() ?? '';

      final firstName =
          (user['firstName'] ?? user['nombres'])?.toString() ?? '';
      final lastName =
          (user['lastName'] ?? user['apellidos'])?.toString() ?? '';
      final userName = '$firstName $lastName'.trim();
      final displayName = userName.isNotEmpty
          ? userName
          : (user['username'] ?? user['usuario'])?.toString() ?? '';

      print('🔍 Rol del usuario recibido: $userRole');
      print('👤 Nombre del usuario: $displayName');

      if (userRole == 'OPERADOR') {
        await _storage.write(key: 'user_id', value: userId);
        await _storage.write(key: 'user_name', value: displayName);
        await _storage.write(key: 'user_role', value: userRole);

        final idEmpresa = user['idEmpresa']?.toString() ?? '0';
        await _storage.write(key: 'id_empresa', value: idEmpresa);
        print('🏢 ID Empresa guardado: $idEmpresa');

        await _locationTrackingService.startTracking(
          userId: userId,
          userName: displayName,
        );

        print('✅ Seguimiento de ubicación iniciado para $displayName');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else if (userRole == 'CLIENTE') {
        await _storage.write(key: 'user_id', value: userId);
        await _storage.write(key: 'user_name', value: displayName);
        await _storage.write(key: 'user_role', value: userRole);

        final idEmpresa = user['idEmpresa']?.toString() ?? '0';
        await _storage.write(key: 'id_empresa', value: idEmpresa);
        print('🏢 ID Empresa guardado: $idEmpresa');

        print('👤 Cliente autenticado: $displayName');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClienteHomeScreen(userData: loginResponse),
            ),
          );
        }
      } else {
        _showMessage('Rol de usuario no autorizado para esta aplicación');
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showRecoveryMessage() {
    _showMessage('Función de recuperación en desarrollo', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackground(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
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
                              direction:
                                  isMobile ? Axis.vertical : Axis.horizontal,
                              children: [
                                if (isMobile)
                                  Padding(
                                    padding: const EdgeInsets.all(36),
                                    child: _LeftLogin(
                                      usernameController: _usernameController,
                                      passwordController: _passwordController,
                                      isMobile: isMobile,
                                      isLoading: _isLoading,
                                      isClientLogin: _isClientLogin,
                                      onLogin: _login,
                                      onForgotPassword: _showRecoveryMessage,
                                    ),
                                  )
                                else
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(36),
                                      child: _LeftLogin(
                                        usernameController:
                                            _usernameController,
                                        passwordController:
                                            _passwordController,
                                        isMobile: isMobile,
                                        isLoading: _isLoading,
                                        isClientLogin: _isClientLogin,
                                        onLogin: _login,
                                        onForgotPassword: _showRecoveryMessage,
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
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isMobile;
  final bool isLoading;
  final bool isClientLogin;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LeftLogin({
    required this.usernameController,
    required this.passwordController,
    required this.isMobile,
    required this.isLoading,
    required this.isClientLogin,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  State<_LeftLogin> createState() => _LeftLoginState();
}

class _LeftLoginState extends State<_LeftLogin> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final usernameLabel = widget.isClientLogin ? 'Correo' : 'Usuario';
    final usernameHint =
        widget.isClientLogin ? 'cliente@dominio.com' : 'usuario';
    final usernameIcon = widget.isClientLogin
        ? Icons.alternate_email_rounded
        : Icons.person_outline_rounded;
    final passwordHint = '••••••••';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(6),
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
              child: Image.asset(
                'assets/images/LOGO COLOR.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AgroAnalytiks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Analitica agronomica para decisiones rapidas',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Inicia sesion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Accede a pronosticos, clima y monitoreo satelital en una sola vista.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Icon(
                widget.isClientLogin
                    ? Icons.alternate_email_rounded
                    : Icons.badge_rounded,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isClientLogin
                          ? 'Acceso cliente detectado'
                          : 'Acceso operador detectado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.isClientLogin
                          ? 'Solo ingresa tu correo para continuar.'
                          : 'Ingresa tu usuario y contrasena para continuar.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        _GlowField(
          label: usernameLabel,
          hint: usernameHint,
          icon: usernameIcon,
          controller: widget.usernameController,
          keyboardType: widget.isClientLogin
              ? TextInputType.emailAddress
              : TextInputType.text,
          enabled: !widget.isLoading,
        ),
        const SizedBox(height: 16),
        if (!widget.isClientLogin) ...[
          _GlowField(
            label: 'Contrasena',
            hint: passwordHint,
            icon: Icons.lock_outline_rounded,
            controller: widget.passwordController,
            obscureText: _hide,
            enabled: !widget.isLoading,
            suffix: IconButton(
              onPressed: widget.isLoading
                  ? null
                  : () => setState(() => _hide = !_hide),
              icon: Icon(
                _hide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              ),
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading ? null : widget.onForgotPassword,
              child: const Text(
                'Olvidaste tu contrasena?',
                style: TextStyle(color: Color(0xFF8BFFC1)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _PrimaryNeonButton(
          text: widget.isLoading ? 'Verificando...' : 'Continuar',
          isLoading: widget.isLoading,
          onPressed: widget.isLoading ? null : widget.onLogin,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o',
                style: TextStyle(color: Colors.white.withOpacity(0.55)),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _GhostButton(
              icon: Icons.g_mobiledata_rounded,
              text: 'Google',
              onPressed: () {},
            ),
            _GhostButton(
              icon: Icons.business_rounded,
              text: 'SSO',
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 18),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Nuevo aqui? ',
                style: TextStyle(color: Colors.white60),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Solicitar demo',
                  style: TextStyle(
                    color: Color(0xFF8BFFC1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.isMobile) ...[
          const SizedBox(height: 18),
          Text(
            'Tip: habilita geolocalizacion para alertas de riesgo y clima hiper-local.',
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
            'Inteligencia agronomica\ncon estetica de producto premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Monitorea salud del cultivo, clima y riesgo fitosanitario con senales claras.\nMenos friccion, mas decision.',
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
                title: 'IA predictiva',
                desc: 'Alertas tempranas de rendimiento y eventos criticos.',
                accent: Color(0xFF2BE7FF),
              ),
              _FeaturePill(
                icon: Icons.wb_sunny_rounded,
                title: 'Clima hiper-local',
                desc: 'Satelite + estaciones para decisiones diarias.',
                accent: Color(0xFFFFC857),
              ),
              _FeaturePill(
                icon: Icons.layers_rounded,
                title: 'Indices de vegetacion',
                desc: 'NDVI / NDRE con lectura ejecutiva.',
                accent: Color(0xFFB18CFF),
              ),
              _FeaturePill(
                icon: Icons.science_rounded,
                title: 'Suelo y foliar',
                desc: 'Nutricion variable basada en datos.',
                accent: Color(0xFF5CFF87),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _MiniStatsCard(),
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
  final bool enabled;

  const _GlowField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.enabled = true,
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
              enabled: widget.enabled,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                  borderSide:
                      const BorderSide(color: Color(0xFF2BE7FF), width: 1.2),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
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
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryNeonButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isLoading
                ? [const Color(0xFF5CFF87), const Color(0xFF5CFF87)]
                : [const Color(0xFF5CFF87), const Color(0xFF2BE7FF)],
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
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Verificando...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              : Text(
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
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 12,
                    height: 1.3,
                  ),
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
          _stat('Cobertura', 'Satelite + estacion'),
          const SizedBox(width: 14),
          _stat('Alertas', 'Riesgo / clima'),
          const SizedBox(width: 14),
          _stat('Indices', 'NDVI / NDRE'),
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
      builder: (context, _) {
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
    final radius = min(w, h);

    orb(
      Offset(w * (0.22 + 0.05 * sin(t * 2 * pi)),
          h * (0.28 + 0.06 * cos(t * 2 * pi))),
      radius * 0.55,
      const Color(0xFF2BE7FF),
    );

    orb(
      Offset(w * (0.78 + 0.06 * cos(t * 2 * pi)),
          h * (0.30 + 0.05 * sin(t * 2 * pi))),
      radius * 0.48,
      const Color(0xFF5CFF87),
    );

    orb(
      Offset(w * (0.55 + 0.04 * sin(t * 2 * pi)),
          h * (0.78 + 0.05 * cos(t * 2 * pi))),
      radius * 0.60,
      const Color(0xFFB18CFF),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) => oldDelegate.t != t;
}

class _NoisePainter extends CustomPainter {
  final _rand = Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
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
