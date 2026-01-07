import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loops_flutter/features/auth/data/repositories/auth_repository_impl.dart';

enum FlowStep {
  initial,
  signInServer,
  signInCustomUrl,
  registerServer,
  registerCustomUrl,
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  FlowStep _currentStep = FlowStep.initial;
  bool _isLoading = false;
  String _selectedServer = 'loops.video';
  final TextEditingController _customUrlController = TextEditingController();

  static const _popularServers = [
    {'label': 'loops.video', 'value': 'loops.video'},
    {'label': 'Other...', 'value': 'other'},
  ];

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  void _transitionTo(FlowStep step) {
    setState(() => _currentStep = step);
  }

  void _handleBack() {
    switch (_currentStep) {
      case FlowStep.signInServer:
        _transitionTo(FlowStep.initial);
        break;
      case FlowStep.signInCustomUrl:
        _transitionTo(FlowStep.signInServer);
        break;
      case FlowStep.registerServer:
        _transitionTo(FlowStep.initial);
        break;
      case FlowStep.registerCustomUrl:
        _transitionTo(FlowStep.registerServer);
        break;
      default:
        break;
    }
  }

  Future<void> _handleSignInSubmit(String serverUrl) async {
    final cleanedUrl = serverUrl
        .toLowerCase()
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authRepositoryProvider)
          .loginWithOAuth(cleanedUrl);
      if (success) {
        if (mounted) context.pushReplacement('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Failed. Check URL and try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegisterSubmit(String serverUrl) async {
    final cleanedUrl = serverUrl
        .toLowerCase()
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authRepositoryProvider)
          .registerWithWebBrowser(cleanedUrl);
      if (success) {
        if (mounted) context.pushReplacement('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration Failed. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    final regex = RegExp(r'^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$');
    return regex.hasMatch(url.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF151518), Colors.black],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case FlowStep.initial:
        return _buildInitial();
      case FlowStep.signInServer:
        return _buildServerSelection(isRegister: false);
      case FlowStep.registerServer:
        return _buildServerSelection(isRegister: true);
      case FlowStep.signInCustomUrl:
        return _buildCustomUrl(isRegister: false);
      case FlowStep.registerCustomUrl:
        return _buildCustomUrl(isRegister: true);
    }
  }

  Widget _buildInitial() {
    return Padding(
      key: const ValueKey('initial'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Loops',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Short videos. Endless creativity.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 20),
          ),
          const Spacer(),
          _PrimaryButton(
            text: 'Sign In',
            onPressed: () => _transitionTo(FlowStep.signInServer),
          ),
          const SizedBox(height: 20),
          _SecondaryButton(
            text: 'Create Account',
            onPressed: () => _transitionTo(FlowStep.registerServer),
          ),
        ],
      ),
    );
  }

  Widget _buildServerSelection({required bool isRegister}) {
    return Padding(
      key: ValueKey('server_${isRegister ? "reg" : "in"}'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackButton(onPressed: _handleBack),
          const SizedBox(height: 24),
          Text(
            'Choose your server',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isRegister
                ? 'Select where to create your account'
                : 'Select where your account is hosted',
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularServers.map((srv) {
              final isSelected = _selectedServer == srv['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedServer = srv['value']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFE500)
                          : Colors.grey[700]!,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    srv['label']!,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? const Color(0xFFFFE500)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          _PrimaryButton(
            text: 'Continue',
            isLoading: _isLoading,
            onPressed: () {
              if (_selectedServer == 'other') {
                _transitionTo(
                  isRegister
                      ? FlowStep.registerCustomUrl
                      : FlowStep.signInCustomUrl,
                );
              } else {
                if (isRegister) {
                  _handleRegisterSubmit(_selectedServer);
                } else {
                  _handleSignInSubmit(_selectedServer);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomUrl({required bool isRegister}) {
    // Re-validate validity on build/state change
    final isValid = _isValidUrl(_customUrlController.text);

    return Padding(
      key: ValueKey('custom_${isRegister ? "reg" : "in"}'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackButton(onPressed: _handleBack),
          const SizedBox(height: 24),
          Text(
            'Enter server URL',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Type your Loops server address',
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333), width: 2),
            ),
            child: Row(
              children: [
                Text(
                  'https://',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _customUrlController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'your.loops.instance',
                      hintStyle: TextStyle(color: Color(0xFF666666)),
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (val) =>
                        setState(() {}), // Trigger rebuild for validation
                    textInputAction: TextInputAction.go,
                    onSubmitted: (val) {
                      if (_isValidUrl(val) && !_isLoading) {
                        if (isRegister) {
                          _handleRegisterSubmit(val);
                        } else {
                          _handleSignInSubmit(val);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Example: loops.video or your.loops.instance',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const Spacer(),
          _PrimaryButton(
            text: isRegister ? 'Create Account' : 'Sign In',
            isLoading: _isLoading,
            onPressed: (!isValid || _isLoading)
                ? null
                : () {
                    if (isRegister) {
                      _handleRegisterSubmit(_customUrlController.text);
                    } else {
                      _handleSignInSubmit(_customUrlController.text);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE500),
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(
            0xFFFFE500,
          ).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFE500),
          side: const BorderSide(color: Color(0xFFFFE500), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        '← Back',
        style: GoogleFonts.inter(color: Colors.blue[400], fontSize: 16),
      ),
    );
  }
}
