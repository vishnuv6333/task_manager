import '../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTask implements UseCase<void, String> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<void> call(String params) async {
    return await repository.deleteTask(params);
  }
}
