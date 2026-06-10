class SensitiveData {
  final String Id;
  final String accessToken;
  final String refreshToken;
  final String email;
  final String password;

  SensitiveData({
    required this.Id,
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "Id": Id,
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "email": email,
      "password": password,
    };
  }

  factory SensitiveData.fromJson(
      Map<String, dynamic> json) {
    return SensitiveData(
      Id: json["Id"],
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      email: json["email"],
      password: json["password"],
    );
  }
}