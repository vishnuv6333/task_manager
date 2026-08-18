import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/task_list_screen.dart';
import 'task_controller.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase = Get.find<LoginUseCase>();
  final SignupUseCase _signupUseCase = Get.find<SignupUseCase>();
  final LogoutUseCase _logoutUseCase = Get.find<LogoutUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase =
      Get.find<GetCurrentUserUseCase>();

  var currentUser = Rxn<User>();
  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final user = await _getCurrentUserUseCase.call(NoParams());
    currentUser.value = user;
    if (user != null) {
      Get.offAll(() => const TaskListScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final user = await _loginUseCase.call(LoginParams(email, password));
      currentUser.value = user;
      Get.offAll(() => const TaskListScreen());
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }
      Get.snackbar(
        'Login Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String email, String password) async {
    isLoading.value = true;
    try {
      final user = await _signupUseCase.call(SignupParams(email, password));
      currentUser.value = user;
      Get.offAll(() => const TaskListScreen());
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }
      Get.snackbar(
        'Signup Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _logoutUseCase.call(NoParams());
      currentUser.value = null;
      // Clear tasks from memory
      if (Get.isRegistered<TaskController>()) {
        Get.find<TaskController>().allTasks.clear();
      }
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar('Logout Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
