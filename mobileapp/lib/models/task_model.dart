class Task {
  final int? id;
  final String title;
  final String description;
  final String cleanDescription;
  final String priority;
  final String? assignedTo;
  final DateTime? dueDate;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.cleanDescription,
    required this.priority,
    this.assignedTo,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      String rawDesc = json['description']?.toString() ?? '';

      String parsedPriority = 'Normalny';
      if (rawDesc.contains('[Priorytet: Wysoki]'))
        parsedPriority = 'Wysoki';
      else if (rawDesc.contains('[Priorytet: Niski]'))
        parsedPriority = 'Niski';

      String? parsedUser;
      final userMatch = RegExp(r'\[Dla: (.*?)\]').firstMatch(rawDesc);
      if (userMatch != null) parsedUser = userMatch.group(1);

      String cleaned = rawDesc
          .replaceAll(RegExp(r'\n?\[Priorytet: .*?\]'), '')
          .replaceAll(RegExp(r'\n?\[Dla: .*?\]'), '')
          .trim();

      return Task(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? ''),
        title: json['title']?.toString() ?? 'Zadanie bez tytulu',
        description: rawDesc,
        cleanDescription: cleaned.isEmpty ? 'Brak opisu' : cleaned,
        priority: parsedPriority,
        assignedTo: parsedUser,
        dueDate: json['due_date'] != null
            ? DateTime.tryParse(json['due_date'].toString())
            : null,
      );
    } catch (e) {
      return Task(
        id: null,
        title: 'Blad formatu zadania',
        description: '',
        cleanDescription: 'Dane tego zadania sa niepelne w bazie.',
        priority: 'Normalny',
      );
    }
  }
}
