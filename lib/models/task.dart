import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  study,
  @HiveField(3)
  habit,
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isComplete;

  @HiveField(2)
  TaskCategory category;

  @HiveField(3)
  DateTime? reminder;

  @HiveField(4)
  String? repeatRule; // simple string description for now

  Task({
    required this.name,
    this.isComplete = false,
    this.category = TaskCategory.work,
    this.reminder,
    this.repeatRule,
  });
}
