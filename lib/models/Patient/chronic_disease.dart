class ChronicDisease {
  final String id;
  final String name;

  const ChronicDisease({
    required this.id,
    required this.name,
  });
  factory ChronicDisease.fromJson(Map<String, dynamic> json) => ChronicDisease(
        id: json['id'],
        name: json['name'],
      );
}