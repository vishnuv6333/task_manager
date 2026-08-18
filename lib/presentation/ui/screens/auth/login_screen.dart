import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle_outline, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val != null && GetUtils.isEmail(val.trim()) ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
                ),
                const SizedBox(height: 32),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () {
                    if (_formKey.currentState!.validate()) {
                      controller.login(_emailController.text.trim(), _passwordController.text.trim());
                    }
                  },
                  child: controller.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('LOGIN'),
                )),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.to(() => const SignupScreen()),
                  child: const Text('Don\'t have an account? Sign up'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
