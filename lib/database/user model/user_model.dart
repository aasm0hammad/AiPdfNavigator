class UserModel {
  String name;
  String email;
  int number;
  dynamic? password;
  bool isComplete;

  UserModel(
      {required this.name,
        required this.email,
        required this.number,
        this.isComplete = false,
        this.password});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'],
        email: map["email"],
        number: map['number'],
        isComplete: map['isComplete']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': number,
      "isComplete": isComplete
    };
  }
}










