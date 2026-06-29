import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // ── Pixel palette ──────────────────────────────────────────
  static const _pink100 = Color(0xFFFFF0F5);
  static const _pink200 = Color(0xFFFFD6E7);
  static const _pink400 = Color(0xFFFF8FB1);
  static const _pink500 = Color(0xFFFF6B9D);
  static const _pink600 = Color(0xFFE8437A);
  static const _pink900 = Color(0xFF3D0020);
  static const _pixelFont = TextStyle(fontFamily: 'monospace', letterSpacing: 1.5);

  Future<void> _register() async {
    if (_emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      _showSnack('✦ Please fill in all fields ✦');
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      _showSnack('✦ Passwords do not match ✦');
      return;
    }
    if (_passCtrl.text.length < 6) {
      _showSnack('✦ Password must be at least 6 characters ✦');
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Registration failed');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: _pixelFont.copyWith(color: Colors.white, fontSize: 12)),
      backgroundColor: _pink600,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // pixel-sharp corners
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pink100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              _PixelBackButton(color: _pink600),
              const SizedBox(height: 20),

              // ── Pixel character / icon ─────────────────────
              _PixelCharacter(),
              const SizedBox(height: 20),

              // ── Title card ────────────────────────────────
              _PixelCard(
                borderColor: _pink500,
                shadowColor: _pink400,
                child: Column(children: [
                  Text('NEW ACCOUNT',
                    style: _pixelFont.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _pink600,
                    )),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _PixelStar(color: _pink400),
                    const SizedBox(width: 6),
                    Text('Register new account',
                      style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
                    const SizedBox(width: 6),
                    _PixelStar(color: _pink400),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Email field ───────────────────────────────
              _PixelLabel('✉ EMAIL ADDRESS'),
              const SizedBox(height: 6),
              _PixelTextField(
                controller: _emailCtrl,
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
                borderColor: _pink400,
                focusColor: _pink500,
              ),
              const SizedBox(height: 16),

              // ── Password field ────────────────────────────
              _PixelLabel('🔒 PASSWORD'),
              const SizedBox(height: 6),
              _PixelTextField(
                controller: _passCtrl,
                hint: '••••••••',
                obscureText: _obscurePass,
                borderColor: _pink400,
                focusColor: _pink500,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: _pink400, size: 18,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 16),

              // ── Confirm password ──────────────────────────
              _PixelLabel('🔒 CONFIRM PASSWORD'),
              const SizedBox(height: 6),
              _PixelTextField(
                controller: _confirmPassCtrl,
                hint: '••••••••',
                obscureText: _obscureConfirm,
                borderColor: _pink400,
                focusColor: _pink500,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: _pink400, size: 18,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 32),

              // ── Register button ───────────────────────────
              _PixelButton(
                label: _loading ? 'CREATING...' : '★  CREATE ACCOUNT  ★',
                onPressed: _loading ? null : _register,
                fillColor: _pink500,
                shadowColor: _pink600,
                textColor: Colors.white,
                loading: _loading,
              ),
              const SizedBox(height: 16),

              // ── Back to login ─────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ',
                  style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('LOGIN',
                    style: _pixelFont.copyWith(
                      fontSize: 10,
                      color: _pink600,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    )),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Decorative pixel dots ─────────────────────
              _PixelDots(color: _pink200),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  Reusable pixel widgets
// ════════════════════════════════════════════

class _PixelCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color shadowColor;
  const _PixelCard({required this.child, required this.borderColor, required this.shadowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 3),
        // Pixel-style hard shadow (offset, no blur)
        boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: child,
    );
  }
}

class _PixelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Color borderColor;
  final Color focusColor;
  final Widget? suffixIcon;

  const _PixelTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    required this.borderColor,
    required this.focusColor,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [BoxShadow(color: borderColor.withOpacity(0.4), offset: const Offset(3, 3), blurRadius: 0)],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14, letterSpacing: 1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'monospace', fontSize: 13,
            color: borderColor.withOpacity(0.5), letterSpacing: 1,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        cursorColor: focusColor,
        cursorWidth: 3,
      ),
    );
  }
}

class _PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color fillColor;
  final Color shadowColor;
  final Color textColor;
  final bool loading;

  const _PixelButton({
    required this.label,
    required this.onPressed,
    required this.fillColor,
    required this.shadowColor,
    required this.textColor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onPressed == null ? fillColor.withOpacity(0.5) : fillColor,
          border: Border.all(color: shadowColor, width: 3),
          boxShadow: onPressed == null
              ? []
              : [BoxShadow(color: shadowColor, offset: const Offset(4, 4), blurRadius: 0)],
        ),
        child: loading
            ? const Center(child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
            : Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2,
                  color: textColor,
                )),
      ),
    );
  }
}

class _PixelLabel extends StatelessWidget {
  final String text;
  const _PixelLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color(0xFFE8437A),
        )),
    );
  }
}

class _PixelBackButton extends StatelessWidget {
  final Color color;
  const _PixelBackButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color, offset: const Offset(2, 2), blurRadius: 0)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.arrow_back_ios_new, size: 12, color: color),
            const SizedBox(width: 4),
            Text('BACK', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}

class _PixelCharacter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // A simple pixel-art style cat face using a CustomPaint
    return SizedBox(
      width: 80, height: 80,
      child: CustomPaint(painter: _PixelCatPainter()),
    );
  }
}

class _PixelCatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = const Color(0xFFFF6B9D);
    final darkPink = const Color(0xFFE8437A);
    final lightPink = const Color(0xFFFFD6E7);
    final white = Colors.white;
    final p = Paint()..style = PaintingStyle.fill;
    final px = size.width / 8; // one pixel unit

    void rect(double x, double y, double w, double h, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(x * px, y * px, w * px, h * px), p);
    }

    // Ears
    rect(0, 0, 2, 2, pink);
    rect(6, 0, 2, 2, pink);
    // Inner ears
    rect(0.5, 0.5, 1, 1, lightPink);
    rect(6.5, 0.5, 1, 1, lightPink);
    // Head
    rect(1, 1, 6, 5, pink);
    // Forehead
    rect(0, 2, 1, 3, pink);
    rect(7, 2, 1, 3, pink);
    // Cheeks
    rect(0, 4, 1, 1, lightPink);
    rect(7, 4, 1, 1, lightPink);
    // Eyes
    rect(2, 2.5, 1.5, 1.5, darkPink);
    rect(4.5, 2.5, 1.5, 1.5, darkPink);
    // Eye shine
    rect(2.3, 2.7, 0.5, 0.5, white);
    rect(4.8, 2.7, 0.5, 0.5, white);
    // Nose
    rect(3.5, 4, 1, 0.5, darkPink);
    // Mouth
    rect(3, 4.5, 0.5, 0.5, darkPink);
    rect(4.5, 4.5, 0.5, 0.5, darkPink);
    // Whiskers
    rect(0.5, 4, 1.5, 0.2, darkPink);
    rect(6, 4, 1.5, 0.2, darkPink);
    // Body
    rect(2, 6, 4, 2, pink);
    // Feet
    rect(1.5, 7.5, 1.5, 0.5, pink);
    rect(5, 7.5, 1.5, 0.5, pink);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PixelStar extends StatelessWidget {
  final Color color;
  const _PixelStar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Text('✦', style: TextStyle(color: color, fontSize: 12));
  }
}

class _PixelDots extends StatelessWidget {
  final Color color;
  const _PixelDots({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: i == 3 ? 10 : 6,
        height: i == 3 ? 10 : 6,
        color: i == 3 ? color.withOpacity(0.8) : color,
      )),
    );
  }
}