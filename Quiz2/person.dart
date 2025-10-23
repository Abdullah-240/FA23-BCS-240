class Person {
  int? id;
  String name;
  String email;
  int age;
  String? image;

  Person({this.id, required this.name, required this.email, required this.age, this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'image': image,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      image: map['image'],
    );
  }
}
