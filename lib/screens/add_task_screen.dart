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
  bool _loading = false;

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')));
      return;
    }
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tasks')
        .add({
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
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
              onPressed: _loading ? null : _save,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Task'))),
        ]),
      ),
    );
  }
}