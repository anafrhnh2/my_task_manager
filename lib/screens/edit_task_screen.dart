import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaskScreen extends StatefulWidget {
  final String docId, title, description;
  const EditTaskScreen({super.key, required this.docId, required this.title, required this.description});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final _titleCtrl = TextEditingController(text: widget.title);
  late final _descCtrl  = TextEditingController(text: widget.description);
  bool _loading = false;

  Future<void> _update() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')));
      return;
    }
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tasks')
        .doc(widget.docId)
        .update({
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
        });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Task title', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _descCtrl, maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _update,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Task'))),
        ]),
      ),
    );
  }
}