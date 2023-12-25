class Student {
  Student({this.id, required this.name});

  int? id;
  final String name;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) =>
      Student(id: map['id'], name: map['name']);
}
