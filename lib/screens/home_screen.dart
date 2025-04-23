import 'package:flutter/material.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/helpers/notification_helper.dart';
import 'package:mystudymate/db/helpers/deadline_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/models/user_model.dart';
import 'package:mystudymate/models/notification_model.dart'
    as CustomNotification;
import 'package:mystudymate/screens/add_edit_task_screen.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';
import 'package:mystudymate/screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TaskHelper _taskHelper;
  late NotificationHelper _notificationHelper;
  late DeadlineHelper _deadlineHelper;
  List<Task> _personalTasks = [];
  List<Task> _assignedTasks = [];
  List<Task> _lecturerTasks = [];
  List<Task> _completedTasks = [];
  List<Task> _completedLecturerTasks = [];
  List<CustomNotification.Notification> _notifications = [];
  bool _isLoading = true;
  late TabController _tabController;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _taskHelper = TaskHelper(DatabaseHelper.instance);
    _notificationHelper = NotificationHelper(DatabaseHelper.instance);
    _deadlineHelper = DeadlineHelper(
      DatabaseHelper.instance,
      _notificationHelper,
    );
    _tabController = TabController(
      length: widget.user.role == 'student' ? 4 : 4,
      vsync: this,
    );
    _loadData();
    _startDeadlineChecker();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (widget.user.role == 'student') {
      _personalTasks = await _taskHelper.getPersonalTasks(widget.user.id!);
      _assignedTasks = await _taskHelper.getAssignedTasks(
        widget.user.school,
        widget.user.department,
        widget.user.level,
      );
      _completedTasks = await _taskHelper.getCompletedTasks(widget.user.id!);
    } else {
      _lecturerTasks = await _taskHelper.getAssignedTasksByLecturer(
        widget.user.id!,
      );
      _completedLecturerTasks = await _taskHelper.getCompletedTasks(
        widget.user.id!,
      );
    }

    _notifications = await _notificationHelper.getNotificationsByUser(
      widget.user.id!,
    );
    _unreadNotifications = _notifications.where((n) => !n.isRead).length;

    setState(() => _isLoading = false);
  }

  void _startDeadlineChecker() {
    _deadlineHelper.checkDeadlines();
    Future.delayed(const Duration(minutes: 15), () {
      _deadlineHelper.checkDeadlines();
      _startDeadlineChecker();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'StudyMate Pro - ${widget.user.role == 'student' ? 'Student' : 'Lecturer'}',
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              NotificationScreen(userId: widget.user.id!),
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
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
          tabs:
              widget.user.role == 'student'
                  ? [
                    const Tab(icon: Icon(Icons.home), text: 'Home'),
                    const Tab(icon: Icon(Icons.assignment), text: 'My Tasks'),
                    const Tab(icon: Icon(Icons.school), text: 'Assigned'),
                    const Tab(
                      icon: Icon(Icons.check_circle),
                      text: 'Completed',
                    ),
                  ]
                  : [
                    const Tab(icon: Icon(Icons.home), text: 'Home'),
                    const Tab(icon: Icon(Icons.add_task), text: 'Create'),
                    const Tab(
                      icon: Icon(Icons.assignment),
                      text: 'Assignments',
                    ),
              
                    const Tab(
                      icon: Icon(Icons.check_circle),
                      text: 'Completed',
                    ),
                  ],
        ),
      ),
      floatingActionButton:
          widget.user.role == 'student' || _tabController.index != 2
              ? FloatingActionButton(
                backgroundColor: Colors.green[700],
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddEditTaskScreen(
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
        children:
            widget.user.role == 'student'
                ? [
                  _buildStudentHome(),
                  _buildTaskList(_personalTasks, false),
                  _buildTaskList(_assignedTasks, true),
                  _buildCompletedTaskList(_completedTasks),
                ]
                : [
                  _buildLecturerHome(),
                  _buildTaskList(_lecturerTasks, true),
                  _buildAssignmentCreation(),
                  _buildCompletedTaskList(_completedLecturerTasks),
                ],
      ),
    );
  }

  Widget _buildStudentHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${widget.user.fullName.split(' ')[0]}! 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Study smarter, not harder with StudyMate Pro',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today, color: Colors.green[700], size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Today\'s Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Active Tasks',
                        '${_personalTasks.length}',
                        Icons.assignment,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Assigned',
                        '${_assignedTasks.length}',
                        Icons.school,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Completed',
                        '${_completedTasks.length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Colors.amber[700],
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Quick Tips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTipItem('Prioritize tasks by deadline'),
                  _buildTipItem('Break large tasks into smaller steps'),
                  _buildTipItem('Review completed tasks weekly'),
                  _buildTipItem('Set personal deadlines before official ones'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_assignedTasks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Assignments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 10),
                ..._assignedTasks
                    .where((task) => task.deadline != null)
                    .take(3) // Safer than sublist
                    .map(
                      (task) => ListTile(
                        leading: Icon(Icons.assignment, color: Colors.blue),
                        title: Text(task.title),
                        subtitle: Text(
                          'Due: ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _tabController.index = 2;
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLecturerHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Professor ${widget.user.fullName.split(' ').last}! 👨‍🏫',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage your courses and assignments efficiently',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Icon(Icons.today, color: Colors.green[700], size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Today\'s Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),

                  // THIS IS WHERE THE STAT CARDS GO
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Active Tasks',
                        '${_personalTasks.length}',
                        Icons.assignment,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Assigned',
                        '${_assignedTasks.length}',
                        Icons.school,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Completed',
                        '${_completedTasks.length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber[700], size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Teaching Tips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTipItem('Give clear assignment instructions'),
                  _buildTipItem('Set realistic deadlines'),
                  _buildTipItem('Provide timely feedback'),
                  _buildTipItem('Use varied assessment methods'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_lecturerTasks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Assignments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 10),
                ..._lecturerTasks
                    .take(3) // Safer than sublist
                    .map(
                      (task) => ListTile(
                        leading: Icon(Icons.assignment, color: Colors.blue),
                        title: Text(task.title),
                        subtitle: Text(
                          task.deadline != null
                              ? 'Due: ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}'
                              : 'No deadline',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _tabController.index = 1;
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.amber[700]),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isAssigned) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          isAssigned ? 'No assigned tasks' : 'No active tasks',
          style: const TextStyle(color: Colors.grey),
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
            if (isCompleted) {
              await _notificationHelper.createNotification(
                CustomNotification.Notification(
                  userId: widget.user.id!,
                  taskId: task.id!,
                  message: 'You completed task: ${task.title}',
                  isRead: false,
                  createdAt: DateTime.now(),
                ),
              );
            }
            _loadData();
          },
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddEditTaskScreen(
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

  Widget _buildCompletedTaskList(List<Task> tasks) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No completed tasks', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          isLecturer: widget.user.role == 'lecturer',
          isCompleted: true,
          onToggleComplete: (isCompleted) async {
            await _taskHelper.toggleTaskCompletion(task.id!, isCompleted);
            _loadData();
          },
          onEdit: null,
          onDelete: null,
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
                  const SizedBox(height: 16),
                  Text(
                    'Assign tasks to students by selecting their school, department, and level. All matching students will be notified.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
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
                            builder:
                                (context) => AddEditTaskScreen(
                                  userId: widget.user.id!,
                                  isAssigned: true,
                                  onTaskSaved: _loadData,
                                ),
                          ),
                        );
                        _loadData();
                      },
                      child: const Text(
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
  final bool isCompleted;
  final Function(bool)? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isLecturer,
    this.isCompleted = false,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onToggleComplete != null)
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) => onToggleComplete!(value ?? false),
                    activeColor: Colors.green[700],
                  ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                ),
                if (!isCompleted && onEdit != null && onDelete != null)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit!();
                      if (value == 'delete') onDelete!();
                    },
                  ),
              ],
            ),
            if (task.description != null) ...[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (task.module != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(task.module!),
                backgroundColor: Colors.green[100],
                labelStyle: TextStyle(color: Colors.green[800]),
              ),
            ],
            if (task.deadline != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(task.category),
                  backgroundColor:
                      task.category == 'group'
                          ? Colors.green[100]
                          : Colors.purple[100],
                  labelStyle: TextStyle(
                    color:
                        task.category == 'group'
                            ? Colors.green[800]
                            : Colors.purple[800],
                  ),
                ),
                if (task.isAssigned)
                  Chip(
                    label: const Text('Assigned'),
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
                if (isCompleted)
                  Chip(
                    label: const Text('Completed'),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(color: Colors.grey[800]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
