import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:orbit_app/features/authentication/presentation/state/auth_state.dart';

final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Login page — Flutter port of the Orbit React design, wired to [AuthCubit].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  /// Client-side validation error (email/password). Server errors come from
  /// the cubit's [AuthState.errorMessage].
  String? _formError;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_emailRegExp.hasMatch(email)) return 'Enter a valid email address.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    final error = _validate();
    if (error != null) {
      setState(() => _formError = error);
      return;
    }
    setState(() => _formError = null);
    context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _onGoogle() {
    FocusScope.of(context).unfocus();
    setState(() => _formError = null);
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _clearErrors() {
    if (_formError != null) setState(() => _formError = null);
    context.read<AuthCubit>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final busy = state.isSubmitting;
            final errorText = _formError ?? state.errorMessage;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // ── Logo header ─────────────────────────────────────────
                  _LogoHeader(),

                  const SizedBox(height: 48),

                  // ── Title block ─────────────────────────────────────────
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to your self-hosted workspace',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Form card ───────────────────────────────────────────
                  _FormCard(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    busy: busy,
                    errorText: errorText,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onChanged: _clearErrors,
                    onSubmit: _onSubmit,
                  ),

                  const SizedBox(height: 32),

                  // ── "or continue with" divider ──────────────────────────
                  const _OrDivider(),

                  const SizedBox(height: 24),

                  // ── Social buttons ──────────────────────────────────────
                  _SocialButtons(busy: busy, onGoogle: _onGoogle),

                  const SizedBox(height: 64),

                  // ── Footer ──────────────────────────────────────────────
                  const _Footer(),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Top-centre logo: small bordered circle + "Orbit" wordmark.
class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 28 px circular border container (size-7 / border-1)
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: kOrbitIndigo.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          child: const Center(child: OrbitIcon(size: 18, strokeWidth: 1.5)),
        ),
        const SizedBox(width: 8),
        const Text(
          'Orbit',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Dark rounded card containing all login form fields.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.busy,
    required this.errorText,
    required this.onTogglePassword,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool busy;
  final String? errorText;
  final VoidCallback onTogglePassword;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16), // rounded-2xl
        border: Border.all(color: AppColors.borderFaint),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner
          if (errorText != null) ...[
            _ErrorBanner(message: errorText!),
            const SizedBox(height: 16),
          ],

          // Email
          const _FieldLabel(label: 'Email'),
          const SizedBox(height: 8),
          _InputField(
            controller: emailController,
            placeholder: 'alex@example.com',
            enabled: !busy,
            onChanged: onChanged,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              size: 16,
              color: AppColors.neutral500,
            ),
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Password
          const _FieldLabel(label: 'Password'),
          const SizedBox(height: 8),
          _InputField(
            controller: passwordController,
            placeholder: '••••••••••',
            enabled: !busy,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmit(),
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: AppColors.neutral500,
            ),
            obscureText: obscurePassword,
            suffixIcon: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
                color: AppColors.neutral500,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Forgot password (handled on the web platform for now)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: kOrbitIndigo,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sign In button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: busy ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrbitIndigo,
                disabledBackgroundColor: kOrbitIndigo.withValues(alpha: 0.5),
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline error message banner shown at the top of the form card.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.googleRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.googleRed.withValues(alpha: 0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.googleRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.googleRed,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Field label with the same style across all form fields.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.neutral400,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.33,
      ),
    );
  }
}

/// Styled text input with prefix/suffix icon support.
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.placeholder,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged == null ? null : (_) => onChanged!(),
      onSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: AppColors.neutral500, fontSize: 14),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: prefixIcon,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: kOrbitIndigo.withValues(alpha: 0.60),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Horizontal divider with "or continue with" label.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.borderFaint)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: AppColors.neutral500,
              fontSize: 12,
              height: 1.33,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.borderFaint)),
      ],
    );
  }
}

/// Full-width Google Sign In button.
class _SocialButtons extends StatelessWidget {
  const _SocialButtons({required this.busy, required this.onGoogle});

  final bool busy;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    return _OutlineButton(
      onTap: busy ? null : onGoogle,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleLogo(size: 18),
          SizedBox(width: 10),
          Text(
            'Continue with Google',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable dark outline button.
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderFaint),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Google "G" logo rendered with CustomPainter — no asset file needed.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final cx = r;
    final cy = r;

    // Draw the four coloured quadrant arcs of the Google G
    final colors = [
      AppColors.googleBlue, // blue  — right
      AppColors.googleGreen, // green — bottom
      AppColors.googleYellow, // yellow — left
      AppColors.googleRed, // red  — top
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..isAntiAlias = true;

    final sweepAngles = [1.65, 1.65, 1.65, 1.65]; // ~94° each
    var startAngle = -0.35; // start just past 12 o'clock (red)
    final arcR = r * 0.72;

    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
        startAngle,
        sweepAngles[i],
        false,
        paint,
      );
      startAngle += sweepAngles[i] + 0.01;
    }

    // White horizontal bar (the crossbar of the G)
    final barPaint = Paint()
      ..color = AppColors.googleBlue
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx,
          cy - size.height * 0.10,
          r * 0.88,
          size.height * 0.20,
        ),
        const Radius.circular(2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}

/// Bottom privacy footer.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.neutral600),
        SizedBox(width: 6),
        Text(
          'Self-hosted · Your data stays yours',
          style: TextStyle(
            color: AppColors.neutral600,
            fontSize: 12,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}
