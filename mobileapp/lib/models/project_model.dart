class ProjectModel {
  final int id;
  final String name;
  final String description;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
