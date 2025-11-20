class Phone {
  final String id;
  final String email;
  final String label;
  final bool isPrimary;
  const Phone({
    required this.id,
    required this.email,
    required this.label,
    required this.isPrimary,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json['id'],
      email: json['phoneNumber'],
      label: json['label'],
      isPrimary: json['isPrimary'],
    );
  }
}
