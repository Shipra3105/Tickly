import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/task.dart';
import 'repositories/task_repository.dart';

final taskRepoProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repo = ref.read(taskRepoProvider);
  return TasksNotifier(repo);
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repo;
  TasksNotifier(this._repo) : super(_repo.getAll());

  void add(Task task) async {
    await _repo.add(task);
    state = _repo.getAll();
  }

  void update(Task task) async {
    await _repo.update(task);
    state = _repo.getAll();
  }

  void delete(Task task) async {
    await _repo.delete(task);
    state = _repo.getAll();
  }
}
