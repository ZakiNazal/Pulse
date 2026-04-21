import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/auth_input_field.dart';

/// Authentication screen with login / register toggle.
///
/// Features:
/// - Animated staggered entrance for all form fields
/// - Smooth cross-fade transition when toggling between Login ↔ Register
/// - Email & password validation
/// - Social login buttons (non-functional)
/// - "Forgot Password?" link (non-functional)
/// - Gradient primary action button
/// - Navigates to home on successful "login"
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  // ── Mode toggle ─────────────────────────────────────────────────────
  bool _isLogin = true;

  // ── Controllers ─────────────────────────────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // only for register

  // ── State ───────────────────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _nameError;

  // ── Animation ───────────────────────────────────────────────────────
  late final AnimationController _pageController;
  late final Animation<double> _pageSlide;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pageSlide = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOutCubic,
    );
    _pageController.value = 1.0; // start fully visible
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  void _toggleMode() {
    _pageController.reverse().then((_) {
      setState(() {
        _isLogin = !_isLogin;
        _emailError = null;
        _passwordError = null;
        _nameError = null;
      });
      _pageController.forward();
    });
  }

  bool _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isLogin) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _nameError = 'Please enter your name');
        return false;
      }
      if (name.length < 2) {
        setState(() => _nameError = 'Name must be at least 2 characters');
        return false;
      }
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return false;
    }

    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address');
      return false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      return false;
    }

    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    // Simulate a brief network call
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate to home
    context.go('/home');
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: AnimatedBuilder(
              animation: _pageSlide,
              builder: (context, _) {
                return Opacity(
                  opacity: _pageSlide.value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - _pageSlide.value)),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // ── Heading ────────────────────────────────
                        _buildHeading(),

                        const SizedBox(height: 8),

                        // ── Subtitle ───────────────────────────────
                        _buildSubtitle(),

                        const SizedBox(height: 36),

                        // ── Form ──────────────────────────────────
                        _buildForm(),

                        const SizedBox(height: 20),

                        // ── Forgot password (login only) ──────────
                        if (_isLogin) _buildForgotPassword(),

                        if (_isLogin) const SizedBox(height: 24),

                        // ── Submit button ─────────────────────────
                        _buildSubmitButton(),

                        const SizedBox(height: 28),

                        // ── Divider ───────────────────────────────
                        _buildDivider(),

                        const SizedBox(height: 24),

                        // ── Social login ──────────────────────────
                        _buildSocialRow(),

                        const SizedBox(height: 32),

                        // ── Toggle mode ───────────────────────────
                        _buildToggle(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────

  Widget _buildHeading() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        _isLogin ? 'Welcome Back' : 'Create Account',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
    );
  }

  Widget _buildSubtitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        _isLogin
            ? 'Sign in to continue to Pulse'
            : 'Join Pulse and never miss a moment',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Name (register only)
        if (!_isLogin)
          AuthInputField(
            label: 'Full Name',
            hint: 'John Doe',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: _nameError,
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.12, end: 0),

        if (!_isLogin) const SizedBox(height: 16),

        // Email
        AuthInputField(
          label: 'Email Address',
          hint: 'you@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          errorText: _emailError,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.12, end: 0),

        const SizedBox(height: 16),

        // Password
        AuthInputField(
          label: 'Password',
          hint: '••••••••',
          controller: _passwordController,
          obscureText: _obscurePassword,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
          errorText: _passwordError,
          onSubmitted: (_) => _submit(),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.12, end: 0),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: implement forgot password
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.footballAccent,
          ),
        ),
      ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedOpacity(
        opacity: _isLoading ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: Colors.transparent,
            // Disable default splash
            foregroundColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.footballAccent,
                  Color(0xFF06B6D4), // teal-400
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 52,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isLogin ? 'Login' : 'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.divider, thickness: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.divider, thickness: 0.5),
        ),
      ],
    ).animate().fadeIn(delay: 450.ms, duration: 400.ms);
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
          onTap: () {},
          child: _buildSvgPlaceholder('G', Colors.white),
          label: 'Google',
        ),
        const SizedBox(width: 20),
        _socialButton(
          onTap: () {},
          child: const Icon(Icons.apple, size: 22, color: Colors.white),
          label: 'Apple',
        ),
        const SizedBox(width: 20),
        _socialButton(
          onTap: () {},
          child: _buildSvgPlaceholder(
            'GH',
            const Color(0xFF6B7280),
          ),
          label: 'GitHub',
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  /// Placeholder for an SVG icon – renders the letter in a circle until
  /// real SVGs are wired up.
  Widget _buildSvgPlaceholder(String letter, Color color) {
    return Text(
      letter,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _socialButton({
    required VoidCallback onTap,
    required Widget child,
    required String label,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return TextButton(
      onPressed: _toggleMode,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: _isLogin
                  ? "Don't have an account? "
                  : 'Already have an account? ',
            ),
            TextSpan(
              text: _isLogin ? 'Sign Up' : 'Login',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.footballAccent,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 550.ms, duration: 400.ms);
  }
}
