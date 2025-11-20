class Email {
  final String id;
  final String email;
  final String label;
  final bool isPrimary;
  const Email({
    required this.id,
    required this.email,
    required this.label,
    required this.isPrimary,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'],
      email: json['emailAddress'],
      label: json['label'],
      isPrimary: json['isPrimary'],
    );
  }
}
