class Allergy {
  final String id;
  final String name;

  const Allergy({
    required this.id,
    required this.name,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id'],
      name: json['name'],
    );
  }
}