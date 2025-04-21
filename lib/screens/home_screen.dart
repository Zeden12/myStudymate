import 'package:flutter/material.dart';
import 'package:mystudymate/db/helpers/task_helper.dart';
import 'package:mystudymate/db/database.dart';
import 'package:mystudymate/models/task_model.dart';
import 'package:mystudymate/models/user_model.dart';
import 'package:mystudymate/screens/add_edit_task_screen.dart';
import 'package:mystudymate/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TaskHelper _taskHelper;
  List<Task> _tasks = [];
  List<Task> _completedTasks = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _taskHelper = TaskHelper(DatabaseHelper.instance);
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _taskHelper.getUpcomingTasks(widget.user.id!);
    final completedTasks = await _taskHelper.getCompletedTasks(widget.user.id!);
    setState(() {
      _tasks = tasks;
      _completedTasks = completedTasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate'),
        actions: [
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
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTaskScreen(
                userId: widget.user.id!,
                onTaskSaved: _loadTasks,
              ),
            ),
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_tasks),
          _buildTaskList(_completedTasks),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks found. Add some!'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggleComplete: (isCompleted) async {
            await _taskHelper.toggleTaskCompletion(task.id!, isCompleted);
            _loadTasks();
          },
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(
                  userId: widget.user.id!,
                  task: task,
                  onTaskSaved: _loadTasks,
                ),
              ),
            );
          },
          onDelete: () async {
            await _taskHelper.deleteTask(task.id!);
            _loadTasks();
          },
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool) onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => onToggleComplete(value ?? false),
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
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
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            if (task.description != null) Text(task.description!),
            if (task.module != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Chip(
                  label: Text(task.module!),
                  backgroundColor: Colors.blue[100],
                ),
              ),
            if (task.deadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
                    ),
                    if (task.deadline!.hour != 0)
                      Text(
                        ' ${task.deadline!.hour}:${task.deadline!.minute.toString().padLeft(2, '0')}',
                      ),
                  ],
                ),
              ),
            Chip(
              label: Text(task.category),
              backgroundColor: task.category == 'group'
                  ? Colors.green[100]
                  : Colors.purple[100],
            ),
          ],
        ),
      ),
    );
  }
}