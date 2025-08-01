class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
  });

  /// **Parse JSON into Category Object**
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      parentId: json['parent_id'],
      children: (json['children'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map((child) => CategoryModel.fromJson(child))
          .toList() ?? [],
    );
  }

  /// **Convert Category Object to JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  /// **Debugging Helper**
  @override
  String toString() {
    return 'Category(id: $id, name: $name, parentId: $parentId, children: ${children.length})';
  }
}
