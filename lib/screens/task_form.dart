import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers.dart';
import '../services/notification_service.dart';

class TaskForm extends ConsumerStatefulWidget {
  final Task? existing;
  const TaskForm({super.key, this.existing});

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  TaskCategory _category = TaskCategory.work;
  DateTime? _reminder;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name);
    _category = widget.existing?.category ?? TaskCategory.work;
    _reminder = widget.existing?.reminder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            DropdownButtonFormField<TaskCategory>(
              value: _category,
              items: TaskCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.toString().split('.').last)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(_reminder == null
                      ? 'No reminder'
                      : DateFormat.yMd().add_jm().format(_reminder!)),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: _reminder ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date == null) return;
                    final time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.fromDateTime(_reminder ?? DateTime.now()));
                    if (time == null) return;
                    setState(() {
                      _reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  },
                )
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final tasksNotifier = ref.read(tasksProvider.notifier);
              int notifyId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

              if (widget.existing != null) {
                widget.existing!
                  ..name = _nameController.text
                  ..category = _category
                  ..reminder = _reminder;
                tasksNotifier.update(widget.existing!);

                if (widget.existing!.key is int) {
                  notifyId = widget.existing!.key as int;
                }
              } else {
                final task = Task(name: _nameController.text, category: _category, reminder: _reminder);
                tasksNotifier.add(task);
              }

              if (_reminder != null && _reminder!.isAfter(DateTime.now())) {
                NotificationService.scheduleNotification(
                    notifyId,
                    'Reminder',
                    _nameController.text,
                    _reminder!);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
