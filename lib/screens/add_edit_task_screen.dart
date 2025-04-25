import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/database.dart';

class AddEditTaskScreen extends StatefulWidget {
  final int userId;
  final Task? task;
  final bool isAssigned;
  final VoidCallback onTaskSaved;

  const AddEditTaskScreen({
    Key? key,
    required this.userId,
    this.task,
    required this.isAssigned,
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
  String? _assignedSchool;
  String? _assignedDepartment;
  String? _assignedLevel;
  bool _isLoading = false;
  bool _isCompleted = false;
  final List<String> _schools = [
    'School of ICT',
    'School of Engineering',
    'School of Science',
  ];
  final List<String> _departments = ['IS', 'CS', 'IT', 'CSE'];
  final List<String> _levels = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description ?? '';
      _category = widget.task!.category;
      _module = widget.task!.module ?? '';
      _deadline = widget.task!.deadline;
      _assignedSchool = widget.task!.assignedSchool;
      _assignedDepartment = widget.task!.assignedDepartment;
      _assignedLevel = widget.task!.assignedLevel;
      _isCompleted = widget.task!.isCompleted;
    } else {
      _title = '';
      _description = '';
      _category = 'individual';
      _module = '';
      _assignedSchool = _schools.first;
      _assignedDepartment = _departments.first;
      _assignedLevel = _levels.first;
      _isCompleted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.task == null
              ? widget.isAssigned
                  ? 'Create Assignment'
                  : 'Add Task'
              : 'Edit ${widget.isAssigned ? 'Assignment' : 'Task'}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.task != null) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value ?? false;
                          });
                        },
                        activeColor: Colors.green[700],
                      ),
                      const Text(
                        'Mark as completed',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  initialValue: _title,
                  decoration: _inputDecoration('Title'),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter a title'
                              : null,
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: _description,
                  decoration: _inputDecoration('Description (optional)'),
                  maxLines: 3,
                  onSaved: (value) => _description = value ?? '',
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(
                      value: 'individual',
                      child: Text('Individual Work'),
                    ),
                    DropdownMenuItem(value: 'group', child: Text('Group Work')),
                  ],
                  decoration: _inputDecoration('Category'),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: _module,
                  decoration: _inputDecoration('Module/Course (optional)'),
                  onSaved: (value) => _module = value ?? '',
                ),
                const SizedBox(height: 16),

                ListTile(
                  title: Text(
                    _deadline == null
                        ? 'Select Deadline (optional)'
                        : 'Deadline: ${DateFormat('dd/MM/yyyy HH:mm').format(_deadline!)}',
                  ),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Colors.green[700],
                  ),
                  onTap: _selectDeadline,
                ),
                const SizedBox(height: 16),

                if (widget.isAssigned) ...[
                  Text(
                    'Assignment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _assignedSchool,
                    items:
                        _schools
                            .map(
                              (school) => DropdownMenuItem(
                                value: school,
                                child: Text(school),
                              ),
                            )
                            .toList(),
                    decoration: _inputDecoration('School'),
                    onChanged:
                        (value) => setState(() => _assignedSchool = value),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _assignedDepartment,
                    items:
                        _departments
                            .map(
                              (dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ),
                            )
                            .toList(),
                    decoration: _inputDecoration('Department'),
                    onChanged:
                        (value) => setState(() => _assignedDepartment = value),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _assignedLevel,
                    items:
                        _levels
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text('Level $level'),
                              ),
                            )
                            .toList(),
                    decoration: _inputDecoration('Level'),
                    onChanged:
                        (value) => setState(() => _assignedLevel = value),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'This assignment will be visible to all students matching the selected school, department and level.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveTask,
                        child: Text(
                          widget.task == null ? 'Save' : 'Update',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.green[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.green[50],
      labelStyle: TextStyle(color: Colors.green[800]),
    );
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            _deadline != null
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
  }

  Future<void> _saveTask() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  setState(() => _isLoading = true);

  final task = Task(
    id: widget.task?.id,
    userId: widget.userId,
    title: _title.trim(),
    description: _description.isNotEmpty ? _description.trim() : null,
    category: _category,
    module: _module.isNotEmpty ? _module.trim() : null,
    deadline: _deadline,
    isCompleted: _isCompleted,
    completedAt: _isCompleted ? DateTime.now() : null, // Set completion time
    isAssigned: widget.isAssigned,
    assignedSchool: widget.isAssigned ? _assignedSchool?.trim() : null,
    assignedDepartment: widget.isAssigned ? _assignedDepartment?.trim() : null,
    assignedLevel: widget.isAssigned ? _assignedLevel?.trim() : null,
  );

  try {
    final taskHelper = TaskHelper(DatabaseHelper.instance);
    
    if (widget.task == null) {
      await taskHelper.insertTask(task);
    } else {
      await taskHelper.updateTask(task);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCompleted 
          ? 'Task marked as completed!' 
          : widget.task == null 
            ? widget.isAssigned 
              ? 'Assignment created successfully!' 
              : 'Task created successfully!'
            : 'Task updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    widget.onTaskSaved();
    if (mounted) Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving task: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
}
