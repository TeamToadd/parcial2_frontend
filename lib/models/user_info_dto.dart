class UserInfoDto {
  final int id;
  final String email;
  final int role; // 1=Empresa, 2=Cliente
  final String? name;
  final String? companyName;

  UserInfoDto({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.companyName,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) => UserInfoDto(
        id: json['id'],
        email: json['email'] ?? '',
        role: json['role'],
        name: json['name'],
        companyName: json['companyName'],
      );
}
