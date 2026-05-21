import 'user_model.dart';

class ProjectModel {
  final int id;
  final String name;
  final String description;
  final List<UserModel> members;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.members = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final members = rawMembers is List
        ? rawMembers
              .map((m) => UserModel.fromJson(m as Map<String, dynamic>))
              .toList()
        : <UserModel>[];

    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      members: members,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
