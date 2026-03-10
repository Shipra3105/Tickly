import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskRepository {
  static const String boxName = 'tasks';

  // Singleton implementation so the same instance is used across app.
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();

  late Box<Task> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskCategoryAdapter());
    _box = await Hive.openBox<Task>(boxName);
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  Future<List<Task>> getAllAsync() async {
    await _ensureInitialized();
    return _box.values.toList();
  }

  List<Task> getAll() {
    if (!_initialized) return <Task>[];
    return _box.values.toList();
  }

  Future<void> add(Task task) async {
    await _ensureInitialized();
    await _box.add(task);
  }

  Future<void> update(Task task) async {
    await _ensureInitialized();
    await task.save();
  }

  Future<void> delete(Task task) async {
    await _ensureInitialized();
    await task.delete();
  }
}
