import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  // ── Pixel pink palette ─────────────────────────────────────
  static const _pink100 = Color(0xFFFFF0F5);
  static const _pink200 = Color(0xFFFFD6E7);
  static const _pink400 = Color(0xFFFF8FB1);
  static const _pink500 = Color(0xFFFF6B9D);
  static const _pink600 = Color(0xFFE8437A);
  static const _pixelFont = TextStyle(fontFamily: 'monospace', letterSpacing: 1.5);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final email = FirebaseAuth.instance.currentUser!.email ?? 'player';
    final username = email.split('@').first.toUpperCase();

    return Scaffold(
      backgroundColor: _pink100,

      // ── Pixel app bar ──────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFFF6B9D), width: 3)),
            boxShadow: [BoxShadow(color: Color(0xFFFF8FB1), offset: Offset(0, 4), blurRadius: 0)],
          ),
        ),
        title: Row(children: [
          SizedBox(
            width: 28, height: 28,
            child: CustomPaint(painter: _MiniCatPainter()),
          ),
          const SizedBox(width: 10),
          Text('MY TASKS',
            style: _pixelFont.copyWith(
              fontSize: 16, fontWeight: FontWeight.bold, color: _pink600)),
        ]),
        actions: [
          // Player badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _pink100,
              border: Border.all(color: _pink400, width: 2),
            ),
            child: Text(username,
              style: _pixelFont.copyWith(fontSize: 9, color: _pink600)),
          ),
          // Logout pixel button
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: _pink600,
                border: Border.all(color: _pink600, width: 2),
                boxShadow: const [BoxShadow(
                  color: Color(0xFFB02050), offset: Offset(2, 2), blurRadius: 0)],
              ),
              child: Text('LOGOUT',
                style: _pixelFont.copyWith(
                  fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users').doc(uid).collection('tasks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // ── Loading ──────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32, height: 32,
                  child: CircularProgressIndicator(color: _pink500, strokeWidth: 3)),
                const SizedBox(height: 12),
                Text('LOADING...', style: _pixelFont.copyWith(fontSize: 11, color: _pink400)),
              ],
            ));
          }

          final docs = snapshot.data?.docs ?? [];

          // ── Empty state ──────────────────────────────────
          if (docs.isEmpty) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: CustomPaint(painter: _SleepingCatPainter()),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _pink400, width: 3),
                    boxShadow: const [BoxShadow(
                      color: Color(0xFFFF8FB1), offset: Offset(4, 4), blurRadius: 0)],
                  ),
                  child: Column(children: [
                    Text('NO QUESTS YET!',
                      style: _pixelFont.copyWith(
                        fontSize: 14, fontWeight: FontWeight.bold, color: _pink600)),
                    const SizedBox(height: 6),
                    Text('TAP  ✦ +  TO ADD YOUR FIRST TASK',
                      style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
                  ]),
                ),
              ],
            ));
          }

          // ── Task list ────────────────────────────────────
          return Column(children: [

            // Stats bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Text('QUESTS', style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
                const SizedBox(width: 8),
                // Pixel progress bar
                Expanded(child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _pink200,
                    border: Border.all(color: _pink400, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (docs.length / (docs.length + 3)).clamp(0.1, 1.0),
                    child: Container(color: _pink500),
                  ),
                )),
                const SizedBox(width: 8),
                Text('${docs.length} ACTIVE',
                  style: _pixelFont.copyWith(fontSize: 10, color: _pink600,
                    fontWeight: FontWeight.bold)),
              ]),
            ),
            Container(height: 3, color: _pink200),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return _PixelTaskCard(
                    index: i,
                    docId: docs[i].id,
                    title: data['title'] ?? '',
                    description: data['description'] ?? '',
                    uid: uid,
                    context: context,
                  );
                },
              ),
            ),
          ]);
        },
      ),

      // ── Pixel FAB ──────────────────────────────────────────
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: _pink500,
            border: Border.all(color: _pink600, width: 3),
            boxShadow: const [BoxShadow(
              color: Color(0xFFB02050), offset: Offset(4, 4), blurRadius: 0)],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
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
            Text('Sign Out?',
              style: _pixelFont.copyWith(
                fontSize: 16, fontWeight: FontWeight.bold, color: _pink600)),
            const SizedBox(height: 8),
            Text('Your progress will be saved.',
              style: _pixelFont.copyWith(fontSize: 10, color: _pink400)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _pink400, width: 3),
                    boxShadow: const [BoxShadow(
                      color: Color(0xFFFF8FB1), offset: Offset(3, 3), blurRadius: 0)],
                  ),
                  child: Text('CANCEL', textAlign: TextAlign.center,
                    style: _pixelFont.copyWith(fontSize: 12, color: _pink600,
                      fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => FirebaseAuth.instance.signOut(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _pink600,
                    border: Border.all(color: _pink600, width: 3),
                    boxShadow: const [BoxShadow(
                      color: Color(0xFFB02050), offset: Offset(3, 3), blurRadius: 0)],
                  ),
                  child: Text('LOGOUT', textAlign: TextAlign.center,
                    style: _pixelFont.copyWith(fontSize: 12, color: Colors.white,
                      fontWeight: FontWeight.bold)),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  Pixel task card
// ════════════════════════════════════════════════════

class _PixelTaskCard extends StatelessWidget {
  final int index;
  final String docId, title, description, uid;
  final BuildContext context;

  static const _pink200 = Color(0xFFFFD6E7);
  static const _pink400 = Color(0xFFFF8FB1);
  static const _pink500 = Color(0xFFFF6B9D);
  static const _pink600 = Color(0xFFE8437A);
  static const _pixelFont = TextStyle(fontFamily: 'monospace', letterSpacing: 1.2);

  const _PixelTaskCard({
    required this.index,
    required this.docId,
    required this.title,
    required this.description,
    required this.uid,
    required this.context,
  });

  void _delete() {
    FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tasks')
        .doc(docId).delete();
  }

  void _edit() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EditTaskScreen(
        docId: docId, title: title, description: description)));
  }

  @override
  Widget build(BuildContext ctx) {
    // Alternate slight tint every other card
    final isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFFFF8FB),
        border: Border.all(color: _pink400, width: 3),
        boxShadow: const [BoxShadow(
          color: Color(0xFFFF8FB1), offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Card header ──────────────────────────────────
        Container(
          color: _pink200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            // Quest number badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: _pink500,
              child: Text('Q${(index + 1).toString().padLeft(2, '0')}',
                style: _pixelFont.copyWith(
                  fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title.toUpperCase(),
                style: _pixelFont.copyWith(
                  fontSize: 12, fontWeight: FontWeight.bold, color: _pink600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status pixel badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _pink500, width: 1.5),
              ),
              child: Text('ACTIVE',
                style: _pixelFont.copyWith(fontSize: 8, color: _pink500)),
            ),
          ]),
        ),

        // ── Description ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Text(
            description.isEmpty ? '— no description —' : description,
            style: _pixelFont.copyWith(
              fontSize: 11, color: description.isEmpty
                ? _pink400 : const Color(0xFF3D0020),
              letterSpacing: 0.8,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ── Divider ───────────────────────────────────────
        Container(height: 2, color: _pink200),

        // ── Action row ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(children: [
            // Mini pixel hearts (decorative)
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: SizedBox(
                width: 10, height: 10,
                child: CustomPaint(painter: _MiniHeartPainter(color: _pink400)),
              ),
            )),
            const Spacer(),

            // Edit button
            GestureDetector(
              onTap: _edit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _pink500, width: 2),
                  boxShadow: const [BoxShadow(
                    color: Color(0xFFFF8FB1), offset: Offset(2, 2), blurRadius: 0)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit, size: 11, color: _pink500),
                  const SizedBox(width: 4),
                  Text('EDIT',
                    style: _pixelFont.copyWith(
                      fontSize: 9, color: _pink500, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(width: 8),

            // Delete button
            GestureDetector(
              onTap: _delete,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _pink600,
                  border: Border.all(color: _pink600, width: 2),
                  boxShadow: const [BoxShadow(
                    color: Color(0xFFB02050), offset: Offset(2, 2), blurRadius: 0)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.delete, size: 11, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('DEL',
                    style: _pixelFont.copyWith(
                      fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════
//  Custom painters
// ════════════════════════════════════════════════════

class _MiniCatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = const Color(0xFFFF6B9D);
    final dark = const Color(0xFFE8437A);
    final p = Paint()..style = PaintingStyle.fill;
    final u = size.width / 7;

    void r(double x, double y, double w, double h, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(x * u, y * u, w * u, h * u), p);
    }

    r(0, 0, 1.5, 1.5, pink);   // left ear
    r(5.5, 0, 1.5, 1.5, pink); // right ear
    r(0.5, 0, 6, 5, pink);     // head
    r(2, 2, 1, 1, dark);       // left eye
    r(4, 2, 1, 1, dark);       // right eye
    r(3, 3, 1, 0.5, dark);     // nose
    r(2.5, 3.5, 0.5, 0.3, dark); // mouth l
    r(4, 3.5, 0.5, 0.3, dark);   // mouth r
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SleepingCatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink  = const Color(0xFFFF6B9D);
    final dark  = const Color(0xFFE8437A);
    final light = const Color(0xFFFFD6E7);
    final p = Paint()..style = PaintingStyle.fill;
    final u = size.width / 8;

    void r(double x, double y, double w, double h, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(x * u, y * u, w * u, h * u), p);
    }

    // Body (curled)
    r(1, 4, 6, 3.5, pink);
    // Head
    r(0, 1, 1.5, 2, pink); // left ear
    r(6.5, 1, 1.5, 2, pink); // right ear
    r(0, 2, 8, 3.5, pink);
    // Closed eyes (Z Z Z sleep)
    r(1.5, 3, 1.5, 0.5, dark);
    r(5, 3, 1.5, 0.5, dark);
    // Blush
    r(0.5, 3.5, 1, 0.5, light);
    r(6.5, 3.5, 1, 0.5, light);
    // Nose
    r(3.5, 3.5, 1, 0.5, dark);
    // Tail
    r(6, 6.5, 2, 1, pink);
    r(7, 5.5, 1, 1, pink);
    // Paws
    r(2, 7, 1.5, 0.5, dark);
    r(4.5, 7, 1.5, 0.5, dark);
    // Z Z Z
    p.color = dark;
    final tp = TextPainter(
      text: TextSpan(text: 'z z z',
        style: TextStyle(fontFamily: 'monospace', fontSize: u * 1.2,
          color: dark, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(u * 2.5, u * 0));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MiniHeartPainter extends CustomPainter {
  final Color color;
  const _MiniHeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final u = size.width / 5;
    const grid = [
      [0,1,0,1,0],
      [1,1,1,1,1],
      [1,1,1,1,1],
      [0,1,1,1,0],
      [0,0,1,0,0],
    ];
    for (var row = 0; row < 5; row++)
      for (var col = 0; col < 5; col++)
        if (grid[row][col] == 1)
          canvas.drawRect(Rect.fromLTWH(col * u, row * u, u, u), p);
  }

  @override
  bool shouldRepaint(_) => false;
}