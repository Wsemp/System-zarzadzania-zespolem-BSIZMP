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
  bool _usersLoading = true;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
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
      if (mounted) {
        setState(() {
          _users = users;
          _usersLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _usersLoading = false);
    }
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

    if (_isEdit) {
      ok = await taskProvider.updateTask(
        widget.task!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        assignedTo: _assignedTo,
        dueDate: _dueDate,
        clearAssignee: _assignedTo == null,
        clearDueDate: _dueDate == null,
      );
    } else {
      ok = await taskProvider.createTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        assignedTo: _assignedTo,
        dueDate: _dueDate,
        // Jawnie przekazujemy projectId z widgetu – nie polegamy na stanie providera
        projectId: widget.projectId,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskProvider.error ?? 'Błąd zapisu'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final initial = _dueDate != null
        ? DateTime.tryParse(_dueDate!) ?? DateTime.now()
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(DateTime.now()) ? DateTime.now() : initial,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edytuj zadanie' : 'Nowe zadanie'),
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
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tytuł zadania *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Pole wymagane' : null,
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
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 20),

              const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 13,
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
                          style: const TextStyle(fontSize: 11),
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
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_usersLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_users.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: _assignedTo,
                  isExpanded: true,
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
                        value: u.id, // int – poprawne
                        child: Text(u.username),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _assignedTo = v),
                ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Termin (opcjonalnie)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _dueDate = null),
                          )
                        : null,
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
                label: _isEdit ? 'Zapisz zmiany' : 'Utwórz zadanie',
                onPressed: _loading ? null : _submit,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
