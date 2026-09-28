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
  late int _notifyMinuteOfDay =
      widget.event?.notifyMinuteOfDay ?? DateEvent.defaultNotifyMinuteOfDay;
  late final Set<int> _notifyDaysBefore = {
    ...(widget.event?.notifyDaysBefore ?? const [0]),
  };

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
    final direction = _inferDirection(_date!);
    final daysBefore = _notifyDaysBefore.toList()..sort();
    final event = DateEvent(
      id: widget.event?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      date: _date!,
      direction: direction,
      emoji: emoji.isEmpty ? null : emoji,
      // A countdown with every reminder chip cleared has nothing to send,
      // so it saves as switched off rather than as an empty promise.
      notify:
          _notify &&
          (direction == CountDirection.since || daysBefore.isNotEmpty),
      notifyMinuteOfDay: _notifyMinuteOfDay,
      notifyDaysBefore: daysBefore,
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

  Future<void> _pickNotifyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (picked != null) {
      setState(() => _notifyMinuteOfDay = picked.hour * 60 + picked.minute);
    }
  }

  TimeOfDay get _timeOfDay => TimeOfDay(
    hour: _notifyMinuteOfDay ~/ 60,
    minute: _notifyMinuteOfDay % 60,
  );

  static String _leadLabel(int daysBefore) {
    return switch (daysBefore) {
      0 => 'On the day',
      1 => '1 day before',
      7 => '1 week before',
      _ => '${dayCountLabel(daysBefore)} before',
    };
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
            if (_date != null) ...[
              const SizedBox(height: 16),
              ..._reminderControls(context),
            ],
          ],
        ),
      ),
    );
  }

  /// The switch, and once it's on, when and (for a countdown) how far ahead.
  /// What the switch means follows the date: a future date announces its
  /// arrival, anything else its milestones — the same inference [_save]
  /// makes, so the controls always describe what will be saved.
  List<Widget> _reminderControls(BuildContext context) {
    final countdown = _inferDirection(_date!) == CountDirection.until;
    final fill = Theme.of(context).inputDecorationTheme.fillColor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const padding = EdgeInsets.symmetric(horizontal: 16);

    return [
      // Takes the fill and radius the text fields get from
      // inputDecorationTheme, so the switch reads as another row of the
      // same form rather than something dropped beside it. Set on the tile
      // itself rather than wrapped in a coloured box: ListTile paints its
      // own background, and listTileTheme supplies a card tone here that
      // would otherwise cover it.
      SwitchListTile(
        value: _notify,
        onChanged: _setNotify,
        tileColor: fill,
        shape: shape,
        contentPadding: padding,
        title: const Text('Remind me'),
        subtitle: Text(
          countdown
              ? 'Before the day arrives'
              : 'At 30, 60, then every 100 days',
        ),
      ),
      if (_notify) ...[
        const SizedBox(height: 8),
        ListTile(
          tileColor: fill,
          shape: shape,
          contentPadding: padding,
          title: const Text('Time'),
          trailing: Text(_timeOfDay.format(context)),
          onTap: _pickNotifyTime,
        ),
        if (countdown) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final days in reminderLeadDays)
                FilterChip(
                  label: Text(_leadLabel(days)),
                  selected: _notifyDaysBefore.contains(days),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _notifyDaysBefore.add(days)
                        : _notifyDaysBefore.remove(days);
                  }),
                ),
            ],
          ),
        ],
      ],
    ];
  }
}
