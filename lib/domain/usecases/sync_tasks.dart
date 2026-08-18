import '../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class SyncTasks implements UseCase<void, NoParams> {
  final TaskRepository repository;

  SyncTasks(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.syncTasks();
  }
}
