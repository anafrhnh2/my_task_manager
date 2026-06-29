import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;

  // ── Pixel pink palette ─────────────────────────────────────
  static const _pink100 = Color(0xFFFFF0F5);
  static const _pink200 = Color(0xFFFFD6E7);
  static const _pink400 = Color(0xFFFF8FB1);
  static const _pink500 = Color(0xFFFF6B9D);
  static const _pink600 = Color(0xFFE8437A);
  static const _pixelFont = TextStyle(fontFamily: 'monospace', letterSpacing: 1.5);

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showSnack('✦ Please fill in all fields ✦');
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Login failed');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: _pixelFont.copyWith(color: Colors.white, fontSize: 12)),
      backgroundColor: _pink600,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pink100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ── Top decorative pixel hearts row ───────────
              _PixelHeartsRow(color: _pink200),
              const SizedBox(height: 24),

              // ── Pixel castle / title card ─────────────────
              _PixelCard(
                borderColor: _pink500,
                shadowColor: _pink400,
                child: Column(children: [
                  _PixelCastleIcon(),
                  const SizedBox(height: 12),
                  Text('TASK MANAGER',
                    style: _pixelFont.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _pink600,
                    )),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('✦', style: TextStyle(color: _pink400, fontSize: 12)),
                    const SizedBox(width: 6),
                    Text('WELCOME BACK, AINA',
                      style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
                    const SizedBox(width: 6),
                    Text('✦', style: TextStyle(color: _pink400, fontSize: 12)),
                  ]),
                ]),
              ),
              const SizedBox(height: 28),


              // ── Email ─────────────────────────────────────
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

              // ── Password ──────────────────────────────────
              _PixelLabel('🔒 PASSWORD'),
              const SizedBox(height: 6),
              _PixelTextField(
                controller: _passCtrl,
                hint: '••••••••',
                obscureText: _obscure,
                borderColor: _pink400,
                focusColor: _pink500,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: _pink400, size: 18,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 32),

              // ── Login button ──────────────────────────────
              _PixelButton(
                label: _loading ? 'LOADING...' : '▶  LOG IN  ◀',
                onPressed: _loading ? null : _login,
                fillColor: _pink500,
                shadowColor: _pink600,
                textColor: Colors.white,
                loading: _loading,
              ),
              const SizedBox(height: 16),

              // ── Divider ───────────────────────────────────
              Row(children: [
                Expanded(child: Container(height: 2, color: _pink200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR', style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
                ),
                Expanded(child: Container(height: 2, color: _pink200)),
              ]),
              const SizedBox(height: 16),

              // ── Register button ───────────────────────────
              _PixelButton(
                label: '✦  CREATE ACCOUNT  ✦',
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
                fillColor: Colors.white,
                shadowColor: _pink400,
                textColor: _pink600,
                loading: false,
              ),
              const SizedBox(height: 28),

            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  Shared pixel widgets  (paste below LoginScreen)
// ════════════════════════════════════════════════════

class _PixelCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color shadowColor;
  const _PixelCard({required this.child, required this.borderColor, required this.shadowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(5, 5), blurRadius: 0)],
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
        boxShadow: [BoxShadow(
          color: borderColor.withOpacity(0.4),
          offset: const Offset(3, 3),
          blurRadius: 0,
        )],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14, letterSpacing: 1),
        cursorColor: focusColor,
        cursorWidth: 3,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'monospace', fontSize: 13,
            color: borderColor.withOpacity(0.5), letterSpacing: 1,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
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
                  fontSize: 13,
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
          fontFamily: 'monospace', fontSize: 11,
          fontWeight: FontWeight.bold, letterSpacing: 1.5,
          color: Color(0xFFE8437A),
        )),
    );
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
        color: i == 3 ? color.withOpacity(0.9) : color,
      )),
    );
  }
}

class _PixelHeartsRow extends StatelessWidget {
  final Color color;
  const _PixelHeartsRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 16, height: 16,
          child: CustomPaint(painter: _PixelHeartPainter(
            color: i < 3 ? const Color(0xFFFF6B9D) : color,
          )),
        ),
      )),
    );
  }
}

class _PixelHeartPainter extends CustomPainter {
  final Color color;
  const _PixelHeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final u = size.width / 5;
    // Pixel heart grid (5×5)
    final grid = [
      [0,1,0,1,0],
      [1,1,1,1,1],
      [1,1,1,1,1],
      [0,1,1,1,0],
      [0,0,1,0,0],
    ];
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (grid[r][c] == 1) {
          canvas.drawRect(Rect.fromLTWH(c * u, r * u, u, u), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PixelCastleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, height: 56,
      child: CustomPaint(painter: _PixelCastlePainter()),
    );
  }
}

class _PixelCastlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink  = const Color(0xFFFF6B9D);
    final dark  = const Color(0xFFE8437A);
    final light = const Color(0xFFFFD6E7);
    final p = Paint()..style = PaintingStyle.fill;
    final u = size.width / 8;

    void rect(double x, double y, double w, double h, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(x * u, y * u, w * u, h * u), p);
    }

    // Battlements
    rect(0, 0, 1.5, 1.5, pink);
    rect(2, 0, 1.5, 1.5, pink);
    rect(4.5, 0, 1.5, 1.5, pink);
    rect(6.5, 0, 1.5, 1.5, pink);
    // Tower tops
    rect(0, 1.5, 3.5, 4, pink);
    rect(4.5, 1.5, 3.5, 4, pink);
    // Tower windows
    rect(1, 2.5, 1.5, 1.5, dark);
    rect(5.5, 2.5, 1.5, 1.5, dark);
    // Window shine
    rect(1.2, 2.7, 0.5, 0.5, light);
    rect(5.7, 2.7, 0.5, 0.5, light);
    // Center wall
    rect(3, 2.5, 2, 3, pink);
    // Gate arch
    rect(3.3, 3.5, 1.4, 2, dark);
    // Wall base
    rect(0, 5.5, 8, 1.5, dark);
    // Gate steps
    rect(3, 6.5, 2, 0.5, pink);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PixelStatBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 – 1.0
  final Color color;
  const _PixelStatBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
        style: TextStyle(fontFamily: 'monospace', fontSize: 10,
          fontWeight: FontWeight.bold, color: color, letterSpacing: 1.5)),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD6E7),
            border: Border.all(color: color, width: 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(color: color),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text('${(value * 100).toInt()}%',
        style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: color)),
    ]);
  }
}