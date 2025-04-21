import 'package:flutter/material.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/helpers/notification_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/models/user_model.dart';
import 'package:mystudymate/models/notification_model.dart' as CustomNotification;
import 'package:mystudymate/screens/add_edit_task_screen.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';
import 'package:mystudymate/screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TaskHelper _taskHelper;
  late NotificationHelper _notificationHelper;
  List<Task> _personalTasks = [];
  List<Task> _assignedTasks = [];
  List<Task> _lecturerTasks = [];
  List<CustomNotification.Notification> _notifications = [];
  bool _isLoading = true;
  late TabController _tabController;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _taskHelper = TaskHelper(DatabaseHelper.instance);
    _notificationHelper = NotificationHelper(DatabaseHelper.instance);
    _tabController = TabController(
      length: widget.user.role == 'student' ? 2 : 3,
      vsync: this,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    if (widget.user.role == 'student') {
      _personalTasks = await _taskHelper.getPersonalTasks(widget.user.id!);
      _assignedTasks = await _taskHelper.getAssignedTasks(
        widget.user.id!,
        widget.user.school!,
        widget.user.department!,
        widget.user.level!,
      );
    } else {
      _lecturerTasks = await _taskHelper.getAssignedTasksByLecturer(widget.user.id!);
    }

    _notifications = await _notificationHelper.getNotificationsByUser(widget.user.id!);
    _unreadNotifications = _notifications.where((n) => !n.isRead).length;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('StudyMate Pro - ${widget.user.role == 'student' ? 'Student' : 'Lecturer'}'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(userId: widget.user.id!),
                    ),
                  );
                  _loadData();
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: widget.user.role == 'student'
              ? [
                  Tab(text: 'Personal Tasks'),
                  Tab(text: 'Assigned Tasks'),
                ]
              : [
                  Tab(text: 'Assigned Tasks'),
                  Tab(text: 'Create Assignments'),
                  Tab(text: 'My Tasks'),
                ],
        ),
      ),
      floatingActionButton: widget.user.role == 'student' || _tabController.index != 1
          ? FloatingActionButton(
              backgroundColor: Colors.green[700],
              child: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTaskScreen(
                      userId: widget.user.id!,
                      isAssigned: false,
                      onTaskSaved: _loadData,
                    ),
                  ),
                );
                _loadData();
              },
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: widget.user.role == 'student'
            ? [
                _buildTaskList(_personalTasks, false),
                _buildTaskList(_assignedTasks, true),
              ]
            : [
                _buildTaskList(_lecturerTasks, true),
                _buildAssignmentCreation(),
                _buildTaskList(_lecturerTasks, false),
              ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isAssigned) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          isAssigned ? 'No assigned tasks' : 'No personal tasks',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          isLecturer: widget.user.role == 'lecturer',
          onToggleComplete: (isCompleted) async {
            await _taskHelper.toggleTaskCompletion(task.id!, isCompleted);
            _loadData();
          },
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(
                  userId: widget.user.id!,
                  task: task,
                  isAssigned: task.isAssigned,
                  onTaskSaved: _loadData,
                ),
              ),
            );
            _loadData();
          },
          onDelete: () async {
            await _taskHelper.deleteTask(task.id!);
            _loadData();
          },
        );
      },
    );
  }

  Widget _buildAssignmentCreation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Assignment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Assign tasks to students by selecting their school, department, and level. All matching students will be notified.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditTaskScreen(
                              userId: widget.user.id!,
                              isAssigned: true,
                              onTaskSaved: _loadData,
                            ),
                          ),
                        );
                        _loadData();
                      },
                      child: Text(
                        'Create New Assignment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isLecturer;
  final Function(bool) onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isLecturer,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!isLecturer || !task.isAssigned)
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) => onToggleComplete(value ?? false),
                    activeColor: Colors.green[700],
                  ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                if (!task.isCompleted)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                  ),
              ],
            ),
            if (task.description != null) ...[
              SizedBox(height: 8),
              Text(
                task.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (task.module != null) ...[
              SizedBox(height: 8),
              Chip(
                label: Text(task.module!),
                backgroundColor: Colors.green[100],
                labelStyle: TextStyle(color: Colors.green[800]),
              ),
            ],
            if (task.deadline != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (task.deadline!.hour != 0)
                    Text(
                      ' ${task.deadline!.hour}:${task.deadline!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(task.category),
                  backgroundColor: task.category == 'group'
                      ? Colors.green[100]
                      : Colors.purple[100],
                  labelStyle: TextStyle(
                    color: task.category == 'group'
                        ? Colors.green[800]
                        : Colors.purple[800],
                  ),
                ),
                if (task.isAssigned)
                  Chip(
                    label: Text('Assigned'),
                    backgroundColor: Colors.blue[100],
                    labelStyle: TextStyle(color: Colors.blue[800]),
                  ),
                if (task.isAssigned && task.assignedSchool != null)
                  Chip(
                    label: Text(task.assignedSchool!),
                    backgroundColor: Colors.orange[100],
                    labelStyle: TextStyle(color: Colors.orange[800]),
                  ),
                if (task.isAssigned && task.assignedDepartment != null)
                  Chip(
                    label: Text(task.assignedDepartment!),
                    backgroundColor: Colors.red[100],
                    labelStyle: TextStyle(color: Colors.red[800]),
                  ),
                if (task.isAssigned && task.assignedLevel != null)
                  Chip(
                    label: Text('Level ${task.assignedLevel}'),
                    backgroundColor: Colors.teal[100],
                    labelStyle: TextStyle(color: Colors.teal[800]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}