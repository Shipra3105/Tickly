import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../providers.dart';
import 'task_form.dart';

// providers moved to providers.dart

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickly'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Slidable(
            key: ValueKey(task.key),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (ctx) async {
                    await showDialog(
                        context: context,
                        builder: (c) => TaskForm(existing: task));
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (ctx) {
                    ref.read(tasksProvider.notifier).delete(task);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: task.isComplete,
                  onChanged: (v) {
                    task.isComplete = v ?? false;
                    ref.read(tasksProvider.notifier).update(task);
                  },
                ),
                title: Text(task.name,
                    style: TextStyle(
                        decoration: task.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none)),
                subtitle: Text(task.category.toString().split('.').last),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(context: context, builder: (c) => const TaskForm());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
