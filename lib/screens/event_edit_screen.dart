import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../services/notification_bridge.dart';
import '../services/notification_schedule.dart';
import '../utils/date_calculations.dart';

/// Returned by [EventEditScreen] when the user deletes the event being
/// edited, distinguishing it from a saved [DateEvent] or a plain cancel.
class DeleteEvent {
  const DeleteEvent();
}

/// How the user is entering the date: straight off a calendar, or as a
/// number of days from today.
enum _DateEntry { onDate, daysFromToday }

/// Which way a day offset counts. Only used while entering "in days" — the
/// saved event stores a date, not an offset.
enum _OffsetDirection { ago, fromNow }

class EventEditScreen extends StatefulWidget {
  const EventEditScreen({super.key, this.event});

  /// The event being edited, or null when creating a new one.
  final DateEvent? event;

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.event?.title,
  );
  late final _emojiController = TextEditingController(
    text: widget.event?.emoji,
  );

  final _offsetController = TextEditingController();

  late DateTime? _date = widget.event?.date;
  _DateEntry _dateEntry = _DateEntry.onDate;
  _OffsetDirection _offsetDirection = _OffsetDirection.fromNow;
  bool _dateError = false;
  late bool _notify = widget.event?.notify ?? false;

  bool get _isEditing => widget.event != null;

  @override
  void dispose() {
    _titleController.dispose();
    _emojiController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  /// Keeps [_date] the single source of truth: "in days" is an input
  /// convenience that resolves to a real date, so nothing downstream — the
  /// model, storage, the widget payload — needs to know it was used.
  void _updateDateFromOffset() {
    if (_dateEntry != _DateEntry.daysFromToday) return;
    final days = int.tryParse(_offsetController.text.trim());
    setState(() {
      _date = days == null
          ? null
          : dateOffsetBy(
              _offsetDirection == _OffsetDirection.fromNow ? days : -days,
            );
      if (_date != null) _dateError = false;
    });
  }

  /// Direction is inferred rather than asked for: a future date counts down,
  /// anything else counts up. Today reads as "0 days" either way, so it falls
  /// to `since`.
  ///
  /// One consequence worth knowing: an `until` event whose date has already
  /// passed used to keep rendering a negative count, and now becomes a
  /// `since` event the next time it's saved.
  CountDirection _inferDirection(DateTime date) {
    return differenceInCalendarDays(DateTime.now(), date) > 0
        ? CountDirection.until
        : CountDirection.since;
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
      id: widget.event?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _date!,
      direction: _inferDirection(_date!),
      emoji: emoji.isEmpty ? null : emoji,
      // Clear the flag if the date moved into the past while the switch was
      // on: the toggle is hidden by then, so leaving it set would be a
      // preference the user can no longer see or change.
      notify: _notify && canNotifyFor(_date!),
    );
    Navigator.pop(context, event);
  }

  /// Asks for permission the first time this is switched on, rather than at
  /// launch — a prompt before the user has asked for anything is the fastest
  /// route to a permanent denial. A refusal leaves the switch off, so the
  /// control never claims something iOS won't do.
  Future<void> _setNotify(bool value) async {
    if (!value) {
      setState(() => _notify = false);
      return;
    }

    final granted = await NotificationBridge.requestPermission();
    if (!mounted) return;
    setState(() => _notify = granted);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turn on notifications for Dayward in Settings.'),
        ),
      );
    }
  }

  void _delete() {
    Navigator.pop(context, const DeleteEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'New Event'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
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
            // No Since/Until control: a future date counts down and a past
            // one counts up, so asking is redundant. See _inferDirection.
            SegmentedButton<_DateEntry>(
              segments: const [
                ButtonSegment(
                  value: _DateEntry.onDate,
                  label: Text('On a date'),
                ),
                ButtonSegment(
                  value: _DateEntry.daysFromToday,
                  label: Text('In days'),
                ),
              ],
              selected: {_dateEntry},
              onSelectionChanged: (selection) {
                setState(() {
                  _dateEntry = selection.first;
                  _dateError = false;
                });
                _updateDateFromOffset();
              },
            ),
            const SizedBox(height: 16),
            if (_dateEntry == _DateEntry.onDate)
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
              )
            else ...[
              TextFormField(
                controller: _offsetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Days',
                  suffixText: 'days',
                ),
                onChanged: (_) => _updateDateFromOffset(),
                validator: (value) {
                  final days = int.tryParse((value ?? '').trim());
                  if (days == null) return 'Enter a number of days';
                  if (days < 0) return 'Enter a positive number of days';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<_OffsetDirection>(
                segments: const [
                  ButtonSegment(
                    value: _OffsetDirection.ago,
                    label: Text('Ago'),
                  ),
                  ButtonSegment(
                    value: _OffsetDirection.fromNow,
                    label: Text('From now'),
                  ),
                ],
                selected: {_offsetDirection},
                onSelectionChanged: (selection) {
                  setState(() => _offsetDirection = selection.first);
                  _updateDateFromOffset();
                },
              ),
              if (_date != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    formatDate(_date!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _emojiController,
              decoration: const InputDecoration(labelText: 'Icon (optional)'),
            ),
            // Only a future date has an arrival to announce, so the
            // control simply isn't offered for anything else.
            if (_date != null && canNotifyFor(_date!)) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                value: _notify,
                onChanged: _setNotify,
                contentPadding: EdgeInsets.zero,
                title: const Text('Remind me on the day'),
                subtitle: const Text('At 9am'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
