import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../utils/date_calculations.dart';

class EventEditScreen extends StatefulWidget {
  const EventEditScreen({super.key});

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _emojiController = TextEditingController();

  DateTime? _date;
  CountDirection _direction = CountDirection.since;
  bool _dateError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateError = false;
      });
    }
  }

  void _save() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _dateError = _date == null);
    if (!formValid || _date == null) {
      return;
    }

    final emoji = _emojiController.text.trim();
    final event = DateEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _date!,
      direction: _direction,
      emoji: emoji.isEmpty ? null : emoji,
    );
    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Event'),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a name for this event';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  errorText: _dateError ? 'Choose a date' : null,
                ),
                child: Text(
                  _date == null ? 'Select a date' : formatDate(_date!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<CountDirection>(
              segments: const [
                ButtonSegment(
                  value: CountDirection.since,
                  label: Text('Since'),
                ),
                ButtonSegment(
                  value: CountDirection.until,
                  label: Text('Until'),
                ),
              ],
              selected: {_direction},
              onSelectionChanged: (selection) {
                setState(() => _direction = selection.first);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emojiController,
              decoration: const InputDecoration(labelText: 'Icon (optional)'),
            ),
          ],
        ),
      ),
    );
  }
}
