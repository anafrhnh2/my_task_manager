import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  bool _loading  = false;
  bool _hasInput = false;

  // ── Pixel pink palette ─────────────────────────────────────
  static const _pink100 = Color(0xFFFFF0F5);
  static const _pink200 = Color(0xFFFFD6E7);
  static const _pink400 = Color(0xFFFF8FB1);
  static const _pink500 = Color(0xFFFF6B9D);
  static const _pink600 = Color(0xFFE8437A);
  static const _pixelFont = TextStyle(fontFamily: 'monospace', letterSpacing: 1.5);

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onChanged);
    _descCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final filled = _titleCtrl.text.isNotEmpty || _descCtrl.text.isNotEmpty;
    if (filled != _hasInput) setState(() => _hasInput = filled);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('✦ Quest title cannot be empty ✦');
      return;
    }
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tasks')
        .add({
          'title':       _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'createdAt':   FieldValue.serverTimestamp(),
        });
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (!_hasInput) return true;
    return await _showDiscardDialog() ?? false;
  }

  Future<bool?> _showDiscardDialog() => showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _pink100,
          border: Border.all(color: _pink500, width: 3),
          boxShadow: const [BoxShadow(
            color: Color(0xFFFF8FB1), offset: Offset(5, 5), blurRadius: 0)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 40, height: 40,
            child: CustomPaint(painter: _PixelTrashPainter()),
          ),
          const SizedBox(height: 12),
          Text('ABANDON QUEST?', style: _pixelFont.copyWith(
            fontSize: 14, fontWeight: FontWeight.bold, color: _pink600)),
          const SizedBox(height: 6),
          Text('Your new quest will not be saved!',
            style: _pixelFont.copyWith(fontSize: 10, color: _pink400),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _DialogBtn(
              label: 'KEEP WRITING',
              fill: Colors.white, border: _pink400,
              shadow: _pink200, textColor: _pink600,
              onTap: () => Navigator.pop(context, false),
            )),
            const SizedBox(width: 10),
            Expanded(child: _DialogBtn(
              label: 'ABANDON',
              fill: _pink600, border: _pink600,
              shadow: const Color(0xFFB02050), textColor: Colors.white,
              onTap: () => Navigator.pop(context, true),
            )),
          ]),
        ]),
      ),
    ),
  );

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: _pixelFont.copyWith(color: Colors.white, fontSize: 11)),
      backgroundColor: _pink600,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _pink100,

        // ── Pixel app bar ──────────────────────────────────
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFFF6B9D), width: 3)),
              boxShadow: [BoxShadow(
                color: Color(0xFFFF8FB1), offset: Offset(0, 4), blurRadius: 0)],
            ),
          ),
          title: Row(children: [
            GestureDetector(
              onTap: () async {
                if (await _onWillPop()) Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _pink100,
                  border: Border.all(color: _pink400, width: 2),
                  boxShadow: const [BoxShadow(
                    color: Color(0xFFFF8FB1), offset: Offset(2, 2), blurRadius: 0)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.arrow_back_ios_new, size: 10, color: _pink600),
                  const SizedBox(width: 4),
                  Text('BACK', style: _pixelFont.copyWith(
                    fontSize: 9, color: _pink600, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Text('NEW QUEST', style: _pixelFont.copyWith(
              fontSize: 15, fontWeight: FontWeight.bold, color: _pink600)),
          ]),
          actions: [
            if (_hasInput)
              _BlinkingBadge(label: 'DRAFTING...', color: _pink500),
            const SizedBox(width: 12),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header card with pixel sword icon ─────────
            _PixelCard(
              borderColor: _pink500,
              shadowColor: _pink400,
              child: Row(children: [
                SizedBox(
                  width: 40, height: 40,
                  child: CustomPaint(painter: _PixelSwordPainter()),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CREATE NEW QUEST', style: _pixelFont.copyWith(
                    fontSize: 13, fontWeight: FontWeight.bold, color: _pink600)),
                  Text('FILL IN THE DETAILS BELOW',
                    style: _pixelFont.copyWith(fontSize: 9, color: _pink400)),
                ]),
                const Spacer(),
                // Quest number badge (sparkle)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _pink200,
                    border: Border.all(color: _pink400, width: 2),
                  ),
                  child: Text('✦ NEW', style: _pixelFont.copyWith(
                    fontSize: 9, color: _pink600, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Tips box ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _pink200,
                border: Border.all(color: _pink400, width: 2),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('💡', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'TIP: Give your quest a clear title so you remember what needs to be done!',
                  style: _pixelFont.copyWith(fontSize: 9, color: _pink600,
                    letterSpacing: 0.8),
                )),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Title field ────────────────────────────────
            _PixelLabel('✦ QUEST TITLE  *'),
            const SizedBox(height: 6),
            _PixelTextField(
              controller: _titleCtrl,
              hint: 'e.g. Siapkan assignment...',
              borderColor: _pink400,
              focusColor: _pink500,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            // Live char count
            ValueListenableBuilder(
              valueListenable: _titleCtrl,
              builder: (_, __, ___) => Align(
                alignment: Alignment.centerRight,
                child: Text('${_titleCtrl.text.length} / 60 CHARS',
                  style: _pixelFont.copyWith(
                    fontSize: 9,
                    color: _titleCtrl.text.length > 60 ? _pink600 : _pink400)),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description field ──────────────────────────
            _PixelLabel('✦ DESCRIPTION  (OPTIONAL)'),
            const SizedBox(height: 6),
            _PixelTextField(
              controller: _descCtrl,
              hint: 'Describe what needs to be done...',
              borderColor: _pink400,
              focusColor: _pink500,
              maxLines: 5,
            ),
            const SizedBox(height: 4),
            ValueListenableBuilder(
              valueListenable: _descCtrl,
              builder: (_, __, ___) => Align(
                alignment: Alignment.centerRight,
                child: Text('${_descCtrl.text.length} CHARS',
                  style: _pixelFont.copyWith(fontSize: 9, color: _pink400)),
              ),
            ),
            const SizedBox(height: 28),

            // ── Live preview ───────────────────────────────
            if (_hasInput) ...[
              _PixelLabel('✦ QUEST PREVIEW'),
              const SizedBox(height: 6),
              ValueListenableBuilder(
                valueListenable: _titleCtrl,
                builder: (_, __, ___) => ValueListenableBuilder(
                  valueListenable: _descCtrl,
                  builder: (_, __, ___) => Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _pink400, width: 3),
                      boxShadow: const [BoxShadow(
                        color: Color(0xFFFF8FB1), offset: Offset(4, 4), blurRadius: 0)],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Card header
                      Container(
                        color: _pink200,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: _pink500,
                            child: Text('Q??', style: _pixelFont.copyWith(
                              fontSize: 9, color: Colors.white,
                              fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _titleCtrl.text.isEmpty
                                ? 'YOUR TITLE HERE...'
                                : _titleCtrl.text.toUpperCase(),
                              style: _pixelFont.copyWith(
                                fontSize: 11, fontWeight: FontWeight.bold,
                                color: _titleCtrl.text.isEmpty ? _pink400 : _pink600),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                        child: Text(
                          _descCtrl.text.isEmpty
                            ? '— no description —'
                            : _descCtrl.text,
                          style: _pixelFont.copyWith(
                            fontSize: 10,
                            color: _descCtrl.text.isEmpty
                              ? _pink400 : const Color(0xFF3D0020),
                            letterSpacing: 0.8),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── Save button ────────────────────────────────
            _PixelButton(
              label: _loading ? 'CREATING QUEST...' : '★  ADD QUEST  ★',
              onPressed: _loading ? null : _save,
              fillColor: _pink500,
              shadowColor: _pink600,
              textColor: Colors.white,
              loading: _loading,
            ),
            const SizedBox(height: 12),

            // ── Cancel button ──────────────────────────────
            _PixelButton(
              label: '✕  CANCEL',
              onPressed: () async {
                if (await _onWillPop()) Navigator.pop(context);
              },
              fillColor: Colors.white,
              shadowColor: _pink400,
              textColor: _pink600,
              loading: false,
            ),
            const SizedBox(height: 24),

            _PixelDots(color: _pink200),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  Reusable pixel widgets
// ════════════════════════════════════════════════════

class _PixelCard extends StatelessWidget {
  final Widget child;
  final Color borderColor, shadowColor;
  const _PixelCard({required this.child, required this.borderColor, required this.shadowColor});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: borderColor, width: 3),
      boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(5, 5), blurRadius: 0)],
    ),
    child: child,
  );
}

class _PixelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color borderColor, focusColor;
  final int maxLines;

  const _PixelTextField({
    required this.controller, required this.hint,
    required this.borderColor, required this.focusColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: borderColor, width: 3),
      boxShadow: [BoxShadow(
        color: borderColor.withOpacity(0.4),
        offset: const Offset(3, 3), blurRadius: 0)],
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'monospace', fontSize: 13, letterSpacing: 1),
      cursorColor: focusColor,
      cursorWidth: 3,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'monospace', fontSize: 12,
          color: borderColor.withOpacity(0.5), letterSpacing: 1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    ),
  );
}

class _PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color fillColor, shadowColor, textColor;
  final bool loading;

  const _PixelButton({
    required this.label, required this.onPressed,
    required this.fillColor, required this.shadowColor,
    required this.textColor, this.loading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: onPressed == null ? fillColor.withOpacity(0.6) : fillColor,
        border: Border.all(color: shadowColor, width: 3),
        boxShadow: onPressed == null ? [] :
          [BoxShadow(color: shadowColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: loading
        ? const Center(child: SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
        : Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold,
              fontSize: 13, letterSpacing: 2, color: textColor)),
    ),
  );
}

class _PixelLabel extends StatelessWidget {
  final String text;
  const _PixelLabel(this.text);

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(
      fontFamily: 'monospace', fontSize: 11,
      fontWeight: FontWeight.bold, letterSpacing: 1.5,
      color: Color(0xFFE8437A))),
  );
}

class _PixelDots extends StatelessWidget {
  final Color color;
  const _PixelDots({required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(7, (i) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: i == 3 ? 10 : 6, height: i == 3 ? 10 : 6,
      color: i == 3 ? color.withOpacity(0.9) : color,
    )),
  );
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final Color fill, border, shadow, textColor;
  final VoidCallback onTap;
  const _DialogBtn({
    required this.label, required this.fill, required this.border,
    required this.shadow, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 3),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(3, 3), blurRadius: 0)],
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'monospace', fontSize: 10,
          fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textColor)),
    ),
  );
}

// ── Blinking badge ─────────────────────────────────────────
class _BlinkingBadge extends StatefulWidget {
  final String label;
  final Color color;
  const _BlinkingBadge({required this.label, required this.color});

  @override
  State<_BlinkingBadge> createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<_BlinkingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  late final Animation<double> _anim = CurvedAnimation(
    parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.color,
        border: Border.all(color: widget.color, width: 1.5),
      ),
      child: Text(widget.label, style: const TextStyle(
        fontFamily: 'monospace', fontSize: 8,
        color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    ),
  );
}

// ── Custom painters ────────────────────────────────────────

class _PixelSwordPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = const Color(0xFFFF6B9D);
    final dark = const Color(0xFFE8437A);
    final light = const Color(0xFFFFD6E7);
    final p = Paint()..style = PaintingStyle.fill;
    final u = size.width / 8;

    void r(double x, double y, double w, double h, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(x * u, y * u, w * u, h * u), p);
    }

    // Blade (top to middle)
    r(3.5, 0,   1, 1,   light);
    r(3.5, 1,   1, 1,   light);
    r(3,   2,   2, 1,   light);
    r(3,   3,   2, 1,   light);
    r(2.5, 4,   3, 1,   light);
    // Guard (crossguard)
    r(1,   5,   6, 1,   dark);
    // Grip
    r(3,   6,   2, 1,   pink);
    r(3,   7,   2, 1,   pink);
    // Pommel
    r(2.5, 8,   3, 0.8, dark);
    // Blade shine
    r(4,   1,   0.5, 3, Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PixelTrashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = const Color(0xFFFF6B9D);
    final dark = const Color(0xFFE8437A);
    final p = Paint()..style = PaintingStyle.fill;
    final u = size.width / 8;

    void r(double x, double y, double w, double h, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(x * u, y * u, w * u, h * u), p);
    }

    // Lid
    r(1, 1, 6, 1, dark);
    r(2.5, 0, 3, 1, dark);
    // Body
    r(1, 2, 6, 5.5, pink);
    // Lines inside
    r(2.5, 3, 0.8, 3.5, dark);
    r(3.8, 3, 0.8, 3.5, dark);
    r(5,   3, 0.8, 3.5, dark);
    // Base
    r(1, 7.5, 6, 0.5, dark);
  }

  @override
  bool shouldRepaint(_) => false;
}