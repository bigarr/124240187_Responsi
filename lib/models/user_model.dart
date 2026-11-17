class UserModel {
  final String username;
  final String password;
  final String fullName;

  UserModel({
    required this.username,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
    );
  }
}
