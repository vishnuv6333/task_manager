import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'presentation/ui/theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/signup_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/task_controller.dart';
import 'data/datasources/task_local_data_source.dart';
import 'data/datasources/task_remote_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/usecases/get_tasks.dart';
import 'domain/usecases/add_task.dart';
import 'domain/usecases/update_task.dart';
import 'domain/usecases/delete_task.dart';
import 'domain/usecases/sync_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  Get.put<TaskLocalDataSource>(TaskLocalDataSourceImpl());
  Get.put<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(firebaseAuth: FirebaseAuth.instance),
  );
  Get.put<TaskRemoteDataSource>(
    TaskRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
  );
  Get.put<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: Get.find<AuthRemoteDataSource>()),
  );
  Get.put<TaskRepository>(
    TaskRepositoryImpl(
      localDataSource: Get.find<TaskLocalDataSource>(),
      remoteDataSource: Get.find<TaskRemoteDataSource>(),
      authRepository: Get.find<AuthRepository>(),
    ),
  );
  Get.put(LoginUseCase(Get.find<AuthRepository>()));
  Get.put(SignupUseCase(Get.find<AuthRepository>()));
  Get.put(LogoutUseCase(Get.find<AuthRepository>()));
  Get.put(GetCurrentUserUseCase(Get.find<AuthRepository>()));

  Get.put(GetTasks(Get.find<TaskRepository>()));
  Get.put(AddTask(Get.find<TaskRepository>()));
  Get.put(UpdateTask(Get.find<TaskRepository>()));
  Get.put(DeleteTask(Get.find<TaskRepository>()));
  Get.put(SyncTasks(Get.find<TaskRepository>()));
  Get.put(AuthController());
  Get.lazyPut(() => TaskController(), fenix: true);

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      debugShowCheckedModeBanner: false,
    );
  }
}
