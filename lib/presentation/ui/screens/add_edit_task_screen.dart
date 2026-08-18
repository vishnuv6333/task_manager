import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../controllers/task_controller.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskController _controller = Get.find<TaskController>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _priority = 'Medium';
  DateTime? _dueDate;

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _priority = widget.task?.priority ?? 'Medium';
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.task != null;

      final task = Task(
        id: isEdit ? widget.task!.id : const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        isCompleted: isEdit ? widget.task!.isCompleted : false,
        createdAt: isEdit ? widget.task!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        userId: isEdit ? widget.task!.userId : '',
      );

      if (isEdit) {
        _controller.updateTask(task);
      } else {
        _controller.addTask(task);
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Task' : 'New Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _priorities.map((p) {
                  return ChoiceChip(
                    label: Text(p),
                    selected: _priority == p,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _priority = p;
                        });
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Due Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _dueDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMd().format(_dueDate!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('SAVE TASK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
