import '../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask implements UseCase<void, Task> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<void> call(Task params) async {
    return await repository.updateTask(params);
  }
}
