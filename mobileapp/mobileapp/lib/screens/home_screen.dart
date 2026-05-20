import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/task_model.dart';
import '../widgets/ui_components.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<Task>> _tasksFuture;
  final _storage = const FlutterSecureStorage();
  String _currentUsername = 'Uzytkowniku';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _tasksFuture = fetchTasks();
  }

  void _loadUsername() async {
    final name = await _storage.read(key: 'username') ?? 'Uzytkowniku';
    setState(() {
      _currentUsername = name;
    });
  }

  Future<List<Task>> fetchTasks() async {
    final token = await _storage.read(key: 'jwt_token');
    final myLogin = await _storage.read(key: 'username') ?? '';
    final url = Uri.parse(
      'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/tasks/',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      List<Task> allTasks = [];
      for (var item in jsonResponse) {
        if (item is Map<String, dynamic>) {
          allTasks.add(Task.fromJson(item));
        }
      }

      List<Task> myTasks = allTasks.where((task) {
        if (task.assignedTo == null) return true;
        return task.assignedTo!.contains(myLogin);
      }).toList();

      return myTasks;
    } else {
      throw Exception('Nie udalo sie pobrac zadan: ${response.statusCode}');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showTaskSheet({Task? taskToEdit}) {
    final titleController = TextEditingController(
      text: taskToEdit?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: taskToEdit?.cleanDescription ?? '',
    );
    final assignedToController = TextEditingController(
      text: taskToEdit?.assignedTo ?? _currentUsername,
    );

    DateTime selectedDueDate = taskToEdit?.dueDate ?? _selectedDate;
    String selectedPriority = taskToEdit?.priority ?? 'Normalny';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        taskToEdit == null ? 'Nowe zadanie' : 'Edytuj zadanie',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 24),

                      buildCustomTextField(
                        controller: titleController,
                        hintText: 'Tytul zadania',
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 12),

                      buildCustomTextField(
                        controller: descriptionController,
                        hintText: 'Opis (opcjonalny)',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      buildCustomTextField(
                        controller: assignedToController,
                        hintText: 'Przypisz do (login)',
                        icon: Icons.person_add_alt_1,
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDueDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Data: ${_formatDate(selectedDueDate)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.edit,
                                size: 16,
                                color: Color(0xFF8C7BFF),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPriority,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF8C7BFF),
                            ),
                            items: <String>['Niski', 'Normalny', 'Wysoki'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      color: value == 'Wysoki'
                                          ? Colors.red
                                          : (value == 'Normalny'
                                                ? Colors.orange
                                                : Colors.green),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setModalState(() {
                                  selectedPriority = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      buildActionButton(
                        text: taskToEdit == null
                            ? 'Zapisz zadanie'
                            : 'Zaktualizuj',
                        color: const Color(0xFF8C7BFF),
                        isLoading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (titleController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tytul nie moze byc pusty!',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isSaving = true;
                                });
                                try {
                                  final token = await _storage.read(
                                    key: 'jwt_token',
                                  );

                                  final urlString = taskToEdit == null
                                      ? 'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/tasks/'
                                      : 'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/tasks/${taskToEdit.id}/';
                                  final url = Uri.parse(urlString);
                                  final method = taskToEdit == null
                                      ? http.post
                                      : http.patch;

                                  String finalDescription =
                                      descriptionController.text;
                                  if (selectedPriority != 'Normalny') {
                                    finalDescription +=
                                        '\n[Priorytet: $selectedPriority]';
                                  }
                                  if (assignedToController.text.isNotEmpty) {
                                    finalDescription +=
                                        '\n[Dla: ${assignedToController.text}]';
                                  }

                                  final response = await method(
                                    url,
                                    headers: {
                                      'Content-Type':
                                          'application/json; charset=UTF-8',
                                      'Authorization': 'Bearer $token',
                                    },
                                    body: jsonEncode({
                                      'title': titleController.text,
                                      'description': finalDescription,
                                      'status': 'todo',
                                      'assigned_to': null,
                                      'tag_ids': [],
                                      'due_date': _formatDate(selectedDueDate),
                                    }),
                                  );

                                  if (response.statusCode == 201 ||
                                      response.statusCode == 200) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          taskToEdit == null
                                              ? 'Dodano zadanie!'
                                              : 'Zaktualizowano!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    setState(() {
                                      _tasksFuture = fetchTasks();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Blad serwera: ${response.statusCode}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Blad: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted)
                                    setModalState(() {
                                      isSaving = false;
                                    });
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'Dzien dobry, $_currentUsername!',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF7A45)),
            onPressed: () async {
              await _storage.delete(key: 'jwt_token');
              await _storage.delete(key: 'username');
              if (mounted)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildDateSelector(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Plan na ten dzien',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _tasksFuture = fetchTasks();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8C7BFF)),
                  );
                if (snapshot.hasError)
                  return Center(
                    child: Text(
                      'Blad: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Center(
                    child: Text(
                      'Brak danych w bazie.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );

                final allTasks = snapshot.data!;

                final filteredTasks = allTasks.where((task) {
                  if (task.dueDate != null) {
                    return task.dueDate!.year == _selectedDate.year &&
                        task.dueDate!.month == _selectedDate.month &&
                        task.dueDate!.day == _selectedDate.day;
                  } else {
                    final now = DateTime.now();
                    return _selectedDate.year == now.year &&
                        _selectedDate.month == now.month &&
                        _selectedDate.day == now.day;
                  }
                }).toList();

                if (filteredTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'Brak zadan na ten dzien! 🎉',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final color = index % 2 == 0
                        ? const Color(0xFFFF7A45)
                        : const Color(0xFF8C7BFF);
                    return _buildTaskCard(task, color);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8C7BFF),
        onPressed: () => _showTaskSheet(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now()
              .subtract(const Duration(days: 1))
              .add(Duration(days: index));
          bool isSelected =
              _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          List<String> weekdays = [
            'Pon',
            'Wto',
            'Sro',
            'Czw',
            'Pia',
            'Sob',
            'Nie',
          ];
          String weekdayName = weekdays[date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8C7BFF) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF8C7BFF).withOpacity(0.4)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task, Color indicatorColor) {
    return GestureDetector(
      onTap: () => _showTaskSheet(taskToEdit: task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      _buildPriorityBadge(task.priority),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.cleanDescription,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (task.assignedTo != null &&
                      task.assignedTo!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          task.assignedTo!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color = Colors.orange;
    if (priority == 'Wysoki') color = Colors.red;
    if (priority == 'Niski') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
