import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loops_flutter/features/auth/data/repositories/auth_repository_impl.dart';

// ─── Flow steps ───────────────────────────────────────────────────────────────

enum _Step {
  welcome,   // initial screen
  email,     // email + password login
  oauth,     // server picker → opens browser
  register,  // server picker for registration
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _Step _step = _Step.welcome;
  bool _loading = false;
  String? _error;

  // shared
  String _server = 'loops.video';

  // email login
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _go(_Step step) => setState(() {
        _step = step;
        _error = null;
      });

  // ── Email/password login ──────────────────────────────────────────────────

  Future<void> _doEmailLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).setInstance(_server);
      final ok = await ref.read(authRepositoryProvider).login(
            email: email,
            password: pass,
          );
      if (ok && mounted) {
        context.go('/');
      } else if (mounted) {
        setState(() => _error = 'Login failed. Check your credentials.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── OAuth / browser login ──────────────────────────────────────────────────

  Future<void> _doOAuth() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok =
          await ref.read(authRepositoryProvider).loginWithOAuth(_server);
      if (ok && mounted) {
        context.go('/');
      } else if (mounted) {
        setState(() =>
            _error = 'Login cancelled or failed. Please try again.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Register via browser ──────────────────────────────────────────────────

  Future<void> _doRegister() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok =
          await ref.read(authRepositoryProvider).registerWithWebBrowser(_server);
      if (ok && mounted) {
        context.go('/');
      } else if (mounted) {
        setState(() => _error = 'Registration cancelled or failed.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.welcome:
        return _WelcomeView(
          onSignIn: () => _go(_Step.email),
          onOAuth: () => _go(_Step.oauth),
          onRegister: () => _go(_Step.register),
        );
      case _Step.email:
        return _EmailLoginView(
          emailCtrl: _emailCtrl,
          passCtrl: _passCtrl,
          obscurePass: _obscurePass,
          server: _server,
          loading: _loading,
          error: _error,
          onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
          onServerChange: (s) => setState(() => _server = s),
          onSubmit: _doEmailLogin,
          onBack: () => _go(_Step.welcome),
        );
      case _Step.oauth:
        return _BrowserAuthView(
          isRegister: false,
          server: _server,
          loading: _loading,
          error: _error,
          onServerChange: (s) => setState(() => _server = s),
          onSubmit: _doOAuth,
          onBack: () => _go(_Step.welcome),
        );
      case _Step.register:
        return _BrowserAuthView(
          isRegister: true,
          server: _server,
          loading: _loading,
          error: _error,
          onServerChange: (s) => setState(() => _server = s),
          onSubmit: _doRegister,
          onBack: () => _go(_Step.welcome),
        );
    }
  }
}

// ─── Welcome ──────────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  const _WelcomeView({
    required this.onSignIn,
    required this.onOAuth,
    required this.onRegister,
  });

  final VoidCallback onSignIn;
  final VoidCallback onOAuth;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // Logo
          const _Logo(),

          const SizedBox(height: 16),
          const Text(
            'Short videos.\nEndless creativity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 18,
              height: 1.4,
            ),
          ),

          const Spacer(flex: 4),

          // Primary CTA
          _Btn(
            label: 'Sign in with email',
            onTap: onSignIn,
          ),
          const SizedBox(height: 12),
          _Btn(
            label: 'Continue with browser',
            style: _BtnStyle.outline,
            icon: Icons.open_in_browser_rounded,
            onTap: onOAuth,
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?  ",
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
              GestureDetector(
                onTap: onRegister,
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Email login ──────────────────────────────────────────────────────────────

class _EmailLoginView extends StatelessWidget {
  const _EmailLoginView({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscurePass,
    required this.server,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onServerChange,
    required this.onSubmit,
    required this.onBack,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscurePass;
  final String server;
  final bool loading;
  final String? error;
  final VoidCallback onToggleObscure;
  final void Function(String) onServerChange;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _BackBtn(onTap: onBack),
          const SizedBox(height: 32),

          const Text(
            'Sign in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to $server',
            style: const TextStyle(color: Colors.white38, fontSize: 15),
          ),

          const SizedBox(height: 32),

          // Server selector
          _ServerChip(
            server: server,
            onChanged: onServerChange,
          ),

          const SizedBox(height: 24),

          _Field(
            controller: emailCtrl,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _Field(
            controller: passCtrl,
            label: 'Password',
            hint: '••••••••',
            obscureText: obscurePass,
            suffix: GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white38,
                size: 20,
              ),
            ),
            onSubmit: onSubmit,
          ),

          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBox(message: error!),
          ],

          const SizedBox(height: 28),

          _Btn(
            label: 'Sign in',
            loading: loading,
            onTap: onSubmit,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Browser auth (OAuth + register) ─────────────────────────────────────────

class _BrowserAuthView extends StatelessWidget {
  const _BrowserAuthView({
    required this.isRegister,
    required this.server,
    required this.loading,
    required this.error,
    required this.onServerChange,
    required this.onSubmit,
    required this.onBack,
  });

  final bool isRegister;
  final String server;
  final bool loading;
  final String? error;
  final void Function(String) onServerChange;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _BackBtn(onTap: onBack),
          const SizedBox(height: 32),

          Text(
            isRegister ? 'Create account' : 'Sign in with browser',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isRegister
                ? 'Choose a server to create your account on'
                : 'A browser will open to complete sign in',
            style: const TextStyle(color: Colors.white38, fontSize: 15),
          ),

          const SizedBox(height: 32),

          _ServerChip(
            server: server,
            onChanged: onServerChange,
          ),

          const Spacer(),

          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.white38, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isRegister
                        ? 'Your browser will open the Loops registration page.'
                        : 'Your browser will open the Loops sign-in page. Return here after authorising.',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (error != null) ...[
            _ErrorBox(message: error!),
            const SizedBox(height: 16),
          ],

          _Btn(
            label: isRegister ? 'Open registration' : 'Open browser to sign in',
            icon: Icons.open_in_browser_rounded,
            loading: loading,
            onTap: onSubmit,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Server chip / picker ─────────────────────────────────────────────────────

class _ServerChip extends StatelessWidget {
  const _ServerChip({required this.server, required this.onChanged});
  final String server;
  final void Function(String) onChanged;

  void _showPicker(BuildContext context) {
    final ctrl = TextEditingController(
        text: server == 'loops.video' ? '' : server);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose server',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _ServerTile(
              label: 'loops.video',
              subtitle: 'Official server',
              selected: server == 'loops.video',
              onTap: () {
                onChanged('loops.video');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Custom server',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              autofocus: false,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'your.loops.instance',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixText: 'https://',
                prefixStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (v) {
                final clean = v.trim()
                    .replaceAll(RegExp(r'^https?://'), '')
                    .replaceAll(RegExp(r'/$'), '');
                if (clean.isNotEmpty) {
                  onChanged(clean);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dns_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(
              server,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more_rounded,
                color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? Colors.white38 : Colors.white12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Shared UI atoms ──────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.loop_rounded, color: Colors.black, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Loops',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

enum _BtnStyle { filled, outline }

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.onTap,
    this.loading = false,
    this.style = _BtnStyle.filled,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final _BtnStyle style;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isFilled = style == _BtnStyle.filled;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isFilled
              ? (loading ? Colors.white60 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isFilled ? null : Border.all(color: Colors.white24),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isFilled ? Colors.black : Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon,
                          size: 18,
                          color: isFilled ? Colors.black : Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isFilled ? Colors.black : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.onSubmit,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction:
              onSubmit != null ? TextInputAction.done : TextInputAction.next,
          onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white38),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white54, size: 16),
          SizedBox(width: 6),
          Text('Back',
              style: TextStyle(color: Colors.white54, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1010),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
