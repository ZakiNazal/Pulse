import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

/// A premium-styled text input field for the Pulse auth screens.
///
/// Features:
/// - Dark surface background with animated focus glow
/// - Optional prefix & suffix icons
/// - Error state with animated red border
/// - Label + hint text support
class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
  });

  /// Label displayed above the field.
  final String label;

  /// Placeholder text inside the field.
  final String? hint;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Keyboard type (e.g. email, phone).
  final TextInputType? keyboardType;

  /// Action for the soft keyboard's action button.
  final TextInputAction? textInputAction;

  /// Whether to hide the text (passwords).
  final bool obscureText;

  /// Icon displayed at the start of the field.
  final Widget? prefixIcon;

  /// Widget displayed at the end of the field (e.g. password toggle).
  final Widget? suffixIcon;

  /// Error message – when non-null the field shows an error state.
  final String? errorText;

  /// Whether the field is interactive.
  final bool enabled;

  /// Whether to auto-focus on mount.
  final bool autofocus;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits (presses done/next).
  final ValueChanged<String>? onSubmitted;

  /// Input formatters (e.g. length limiters).
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum character length.
  final int? maxLength;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();

  /// Drives the border colour / glow transition.
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    _focusNode.addListener(_syncGlow);
  }

  @override
  void didUpdateWidget(covariant AuthInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText != widget.errorText) _syncGlow();
  }

  void _syncGlow() {
    (_focusNode.hasFocus || _hasError)
        ? _glowController.forward()
        : _glowController.reverse();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_syncGlow);
    _focusNode.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _hasError ? AppColors.errorRed : AppColors.footballAccent;
    final glow = _hasError
        ? AppColors.errorRed.withValues(alpha: 0.35)
        : AppColors.footballAccent.withValues(alpha: 0.30);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) {
        final t = _glowAnim.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Label ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // ── Field container ─────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color.lerp(AppColors.glassBorder, accent, t)!,
                  width: 0.5 + 1.0 * t, // 0.5 → 1.5
                ),
                boxShadow: t > 0
                    ? [
                        BoxShadow(
                          color: glow,
                          blurRadius: 12 * t,
                          spreadRadius: 1 * t,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                inputFormatters: widget.inputFormatters,
                maxLength: widget.maxLength,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: IconTheme(
                            data: const IconThemeData(
                              size: 20,
                              color: AppColors.textTertiary,
                            ),
                            child: widget.prefixIcon!,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: widget.suffixIcon!,
                        )
                      : null,
                  // Strip all Material borders – we draw our own.
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  counterText: '',
                  isDense: true,
                ),
              ),
            ),

            // ── Error text ──────────────────────────────────────────
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 6),
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.errorRed,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
