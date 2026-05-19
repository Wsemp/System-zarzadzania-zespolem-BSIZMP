import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/task_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/gradient_button.dart';

class TaskFormScreen extends StatefulWidget {
  final int? projectId;
  final TaskModel? task;

  const TaskFormScreen({super.key, this.projectId, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskStatus _status = TaskStatus.todo;
  int? _assignedTo;
  String? _dueDate;
  List<UserModel> _users = [];
  bool _loading = false;

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final t = widget.task!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _status = t.status;
      _assignedTo = t.assignedTo;
      _dueDate = t.dueDate;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await UserService.getUsers();
      setState(() => _users = users);
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final taskProvider = context.read<TaskProvider>();
    bool ok;

    if (isEdit) {
      ok = await taskProvider.updateTask(widget.task!.id, {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'status': _status.value,
        'assigned_to': _assignedTo,
        'due_date': _dueDate,
      });
    } else {
      ok = await taskProvider.createTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        assignedTo: _assignedTo,
        dueDate: _dueDate,
      );
    }

    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskProvider.error ?? 'Błąd zapisu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edytuj zadanie' : 'Nowe zadanie'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tytuł zadania *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Pole wymagane' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Opis',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskStatus>(
                segments: TaskStatus.values
                    .map(
                      (s) => ButtonSegment(
                        value: s,
                        label: Text(
                          s.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                    .toList(),
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.purple
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_users.isNotEmpty) ...[
                DropdownButtonFormField<int?>(
                  value: _assignedTo,
                  decoration: const InputDecoration(
                    labelText: 'Przypisz do',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Nieprzypisane'),
                    ),
                    ..._users.map(
                      (u) => DropdownMenuItem(
                        value: u.id,
                        child: Text(u.username),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _assignedTo = v),
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Termin',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _dueDate ?? 'Wybierz datę',
                    style: TextStyle(
                      color: _dueDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: isEdit ? 'Zapisz zmiany' : 'Utwórz zadanie',
                onPressed: _loading ? null : _submit,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.purple),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _dueDate = date.toIso8601String().substring(0, 10));
    }
  }
}
