import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/helpers/notification_helper.dart';
import 'package:mystudymate/db/helpers/user_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/notification_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final int userId;
  final Task? task;
  final bool isAssigned; // True if creating/editing an assignment
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
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  late String _title;
  late String _description;
  late String _category;
  late String _module;
  DateTime? _deadline;
  
  // Assignment-specific fields
  String? _assignedSchool;
  String? _assignedDepartment;
  String? _assignedLevel;
  
  // UI state
  bool _isLoading = false;

  // Dropdown options
  final List<String> _schools = ['School of Engineering', 'School of Medicine', 'School of Arts'];
  final List<String> _departments = ['Computer Science', 'Electrical Engineering', 'Mechanical Engineering'];
  final List<String> _levels = ['100', '200', '300', '400'];

  @override
  void initState() {
    super.initState();
    // Initialize form fields with task data if editing
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description ?? '';
      _category = widget.task!.category;
      _module = widget.task!.module ?? '';
      _deadline = widget.task!.deadline;
      _assignedSchool = widget.task!.assignedSchool;
      _assignedDepartment = widget.task!.assignedDepartment;
      _assignedLevel = widget.task!.assignedLevel;
    } else {
      // Default values for new task
      _title = '';
      _description = '';
      _category = 'individual';
      _module = '';
      _assignedSchool = _schools.first;
      _assignedDepartment = _departments.first;
      _assignedLevel = _levels.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.task == null 
            ? widget.isAssigned ? 'Create Assignment' : 'Add Task' 
            : 'Edit ${widget.isAssigned ? 'Assignment' : 'Task'}'
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                _buildTitleField(),
                const SizedBox(height: 16),
                
                // Description Field
                _buildDescriptionField(),
                const SizedBox(height: 16),
                
                // Category Dropdown
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                
                // Module/Course Field
                _buildModuleField(),
                const SizedBox(height: 16),
                
                // Deadline Picker
                _buildDeadlinePicker(),
                const SizedBox(height: 16),
                
                // Assignment-specific fields (only shown for assignments)
                if (widget.isAssigned) _buildAssignmentFields(),
                
                // Save/Update Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the title input field
  Widget _buildTitleField() {
    return TextFormField(
      initialValue: _title,
      decoration: _inputDecoration('Title'),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
      onSaved: (value) => _title = value!,
    );
  }

  // Widget for the description input field
  Widget _buildDescriptionField() {
    return TextFormField(
      initialValue: _description,
      decoration: _inputDecoration('Description (optional)'),
      maxLines: 3,
      onSaved: (value) => _description = value ?? '',
    );
  }

  // Widget for the category dropdown
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      items: const [
        DropdownMenuItem(value: 'individual', child: Text('Individual Work')),
        DropdownMenuItem(value: 'group', child: Text('Group Work')),
      ],
      decoration: _inputDecoration('Category'),
      onChanged: (value) => _category = value!,
    );
  }

  // Widget for the module/course input field
  Widget _buildModuleField() {
    return TextFormField(
      initialValue: _module,
      decoration: _inputDecoration('Module/Course (optional)'),
      onSaved: (value) => _module = value ?? '',
    );
  }

  // Widget for the deadline picker
  Widget _buildDeadlinePicker() {
    return ListTile(
      title: Text(
        _deadline == null
            ? 'Select Deadline (optional)'
            : 'Deadline: ${DateFormat('dd/MM/yyyy HH:mm').format(_deadline!)}',
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.green[700]),
      onTap: _selectDeadline,
    );
  }

  // Widget for assignment-specific fields
  Widget _buildAssignmentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignment Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 16),
        
        // School Dropdown
        DropdownButtonFormField<String>(
          value: _assignedSchool,
          items: _schools.map((school) => 
            DropdownMenuItem(value: school, child: Text(school))
          ).toList(),
          decoration: _inputDecoration('School'),
          onChanged: (value) => setState(() => _assignedSchool = value),
        ),
        const SizedBox(height: 16),
        
        // Department Dropdown
        DropdownButtonFormField<String>(
          value: _assignedDepartment,
          items: _departments.map((dept) => 
            DropdownMenuItem(value: dept, child: Text(dept))
          ).toList(),
          decoration: _inputDecoration('Department'),
          onChanged: (value) => setState(() => _assignedDepartment = value),
        ),
        const SizedBox(height: 16),
        
        // Level Dropdown
        DropdownButtonFormField<String>(
          value: _assignedLevel,
          items: _levels.map((level) => 
            DropdownMenuItem(value: level, child: Text('Level $level'))
          ).toList(),
          decoration: _inputDecoration('Level'),
          onChanged: (value) => setState(() => _assignedLevel = value),
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
    );
  }

  // Widget for the submit button
  Widget _buildSubmitButton() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _saveTask,
              child: Text(
                widget.task == null ? 'Save' : 'Update',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
  }

  // Helper method for input decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.green[50],
    );
  }

  // Method to select deadline
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
  }

  // Method to save/update task
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);

    // Create task object from form data
    final task = Task(
      id: widget.task?.id,
      userId: widget.userId,
      title: _title,
      description: _description.isNotEmpty ? _description : null,
      category: _category,
      module: _module.isNotEmpty ? _module : null,
      deadline: _deadline,
      isAssigned: widget.isAssigned,
      assignedSchool: widget.isAssigned ? _assignedSchool : null,
      assignedDepartment: widget.isAssigned ? _assignedDepartment : null,
      assignedLevel: widget.isAssigned ? _assignedLevel : null,
    );

    try {
      final taskHelper = TaskHelper(DatabaseHelper.instance);
      final notificationHelper = NotificationHelper(DatabaseHelper.instance);
      final userHelper = UserHelper(DatabaseHelper.instance);

      if (widget.task == null) {
        // Create new task
        final taskId = await taskHelper.insertTask(task);
        
        // Create notifications if this is an assignment
        if (widget.isAssigned) {
          final matchingStudents = await userHelper.getStudentsByCriteria(
            _assignedSchool!,
            _assignedDepartment!,
            _assignedLevel!,
          );
          await notificationHelper.createAssignmentNotifications(
            taskId,
            _title,
            matchingStudents,
          );
        }
      } else {
        // Update existing task
        await taskHelper.updateTask(task);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task == null 
            ? widget.isAssigned 
              ? 'Assignment created successfully!' 
              : 'Task created successfully!'
            : 'Task updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Notify parent and close screen
      widget.onTaskSaved();
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}