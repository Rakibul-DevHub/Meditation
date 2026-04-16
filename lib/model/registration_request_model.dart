class RegistrationRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  RegistrationRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}