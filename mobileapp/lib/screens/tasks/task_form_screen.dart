import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
          backgroundColor: AppColors.error,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputCard(),
                      const SizedBox(height: 16),
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      _buildAssigneeCard(),
                      const SizedBox(height: 16),
                      _buildDateCard(),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _isEdit ? 'Zapisz zmiany' : 'Utwórz zadanie',
                        onPressed: _loading ? null : _submit,
                        isLoading: _loading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isEdit ? 'Edytuj zadanie' : 'Nowe zadanie',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  Text _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      fontSize: 13,
    ),
  );

  Widget _buildInputCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Tytuł zadania'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleCtrl,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.title_rounded),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Pole wymagane' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descCtrl,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Opis',
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Status'),
          const SizedBox(height: 12),
          SegmentedButton<TaskStatus>(
            segments: TaskStatus.values
                .map(
                  (s) => ButtonSegment(
                    value: s,
                    label: Text(
                      s.label,
                      style: GoogleFonts.poppins(fontSize: 11),
                    ),
                  ),
                )
                .toList(),
            selected: {_status},
            onSelectionChanged: (s) => setState(() => _status = s.first),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Przypisanie'),
          const SizedBox(height: 12),
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Nieprzypisane',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                ),
                ..._users.map(
                  (u) => DropdownMenuItem(
                    value: u.id,
                    child: Text(u.username, style: GoogleFonts.poppins()),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _assignedTo = v),
            ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Termin'),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                suffixIcon: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _dueDate = null),
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              child: Text(
                _dueDate ?? 'Wybierz datę',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _dueDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
