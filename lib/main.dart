import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'ui/theme.dart';
import 'ui/screens/task_list_screen.dart';
import 'controllers/task_controller.dart';
import 'repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: \$e");
  }

  // Dependency Injection using GetX
  Get.put(TaskRepository());
  Get.put(TaskController());

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
