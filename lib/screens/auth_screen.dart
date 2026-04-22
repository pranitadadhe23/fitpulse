// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _bgController;
  late Animation<double> _bgAnim;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _bgAnim = Tween<double>(begin: 0, end: 1).animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    context.read<AuthProvider>().clearError();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isLogin) {
      success = await authProvider.signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    } else {
      success = await authProvider.signUp(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text,
      );
    }

    if (!success && mounted) {
      showErrorSnackBar(context, authProvider.errorMessage ?? 'An error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, child) => Stack(
          children: [
            // Animated background
            Container(
              decoration: const BoxDecoration(color: AppColors.bg),
            ),
            Positioned(
              top: -100 + (_bgAnim.value * 30),
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.neonCyan.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100 + (_bgAnim.value * 20),
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.neonPurple.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child!,
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.08),
                _buildHeader(),
                SizedBox(height: size.height * 0.06),
                _buildForm(),
                const SizedBox(height: 24),
                _buildToggle(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppColors.cyanGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(Icons.bolt, color: AppColors.bg, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'FITPULSE',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isLogin ? 'Welcome\nBack.' : 'Create\nAccount.',
            key: ValueKey(_isLogin),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              height: 1.1,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Sign in to continue your journey'
              : 'Start your fitness journey today',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (!_isLogin) ...[
              _buildTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
            ],
            _buildTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 28),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => NeonButton(
                label: _isLogin ? 'Sign In' : 'Create Account',
                isLoading: auth.status == AuthStatus.loading,
                onPressed: _submit,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Exo2'),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account? " : 'Already have an account? ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
