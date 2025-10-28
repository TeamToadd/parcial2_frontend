class UserRegisterDto {
  final String email;
  final String password;
  final int role; // 1=Empresa, 2=Cliente

  final String? name;
  final String? lastName;
  final String? userName;
  final String? address;
  final String? phone;
  final String? profileImageUrl;
  final String? companyName;

  UserRegisterDto({
    required this.email,
    required this.password,
    required this.role,
    this.name,
    this.lastName,
    this.userName,
    this.address,
    this.phone,
    this.profileImageUrl,
    this.companyName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'role': role,
        'name': name,
        'lastName': lastName,
        'userName': userName,
        'address': address,
        'phone': phone,
        'profileImageUrl': profileImageUrl,
        'companyName': companyName,
      };
}
