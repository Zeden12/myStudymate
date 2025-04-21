import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/database.dart';

class AddEditTaskScreen extends StatefulWidget {
  final int userId;
  final Task? task;
  final VoidCallback onTaskSaved;

  const AddEditTaskScreen({
    Key? key,
    required this.userId,
    this.task,
    required this.onTaskSaved,
  }) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _category;
  late String _module;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description ?? '';
      _category = widget.task!.category;
      _module = widget.task!.module ?? '';
      _deadline = widget.task!.deadline;
    } else {
      _title = '';
      _description = '';
      _category = 'individual';
      _module = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(
                    value: 'individual',
                    child: Text('Individual Work'),
                  ),
                  DropdownMenuItem(
                    value: 'group',
                    child: Text('Group Work'),
                  ),
                ],
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _module,
                decoration: const InputDecoration(labelText: 'Module/Course (optional)'),
                onSaved: (value) => _module = value ?? '',
              ),
              ListTile(
                title: Text(
                  _deadline == null
                      ? 'Select Deadline (optional)'
                      : 'Deadline: ${DateFormat('dd/MM/yyyy HH:mm').format(_deadline!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _deadline != null
                          ? TimeOfDay.fromDateTime(_deadline!)
                          : TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _deadline = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Save Task'),
                onPressed: _saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final task = Task(
        id: widget.task?.id,
        userId: widget.userId,
        title: _title,
        description: _description.isNotEmpty ? _description : null,
        category: _category,
        module: _module.isNotEmpty ? _module : null,
        deadline: _deadline,
      );

      if (widget.task == null) {
        await TaskHelper(DatabaseHelper.instance).insertTask(task);
      } else {
        await TaskHelper(DatabaseHelper.instance).updateTask(task);
      }

      widget.onTaskSaved();
      Navigator.pop(context);
    }
  }
}