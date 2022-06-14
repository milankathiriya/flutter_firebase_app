class Employee {
  final String? name;
  final int? age;
  final String? role;

  Employee({
    required this.name,
    required this.age,
    required this.role,
  });

  factory Employee.fromMap(Map<String, dynamic> data) {
    return Employee(
      name: data['name'],
      age: data['age'],
      role: data['role'],
    );
  }
}
