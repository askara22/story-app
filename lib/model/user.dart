import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String? name;
  String? email;
  String? password;

  User({
    this.name,
    this.email,
    this.password,
  });

  @override
  String toString() => 'User(name: $name, email: $email, password: $password)';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }

  factory User.fromJson(json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.name == name &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(name, email, password);
}
