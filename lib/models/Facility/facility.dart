class Facility {
  final String id;
  final String name;
  final int? type;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? fullAddress;
  final double? gpsLatitude;
  final double? gpsLongitude;

  const Facility({
    required this.id,
    required this.name,
    this.type,
    this.street,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.fullAddress,
    this.gpsLatitude,
    this.gpsLongitude,
  });

  /// ------------------------
  /// Factory: Main Facility API
  /// ------------------------
  factory Facility.fromFacilityApi(Map<String, dynamic> json) {
    final address = json['Address'] ?? {};

    return Facility(
      id: json['Id'] ,
      name: json['Name'] ,
      type: json['Type'],
      street: address['street'],
      city: address['city'],
      country: address['country'],
      zipCode: address['zipCode'],
      fullAddress:
          address['fullAddress'] ??
          '${address['street'] }, ${address['city'] }, ${address['country'] } ${address['zipCode'] }',
      gpsLatitude:json['GPSLatitude'],
      gpsLongitude: json['GPSLongitude']
    );
  }

  /// ------------------------
  /// Factory: AppointmentFacility API
  /// ------------------------
  factory Facility.fromAppointmentApi(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] ,
      name: json['name'] ,
      fullAddress: json['address'],
    );
  }

  /// ------------------------
  /// Factory: AppointmentDetailsFacility API
  /// ------------------------
  factory Facility.fromAppointmentDetailsApi(Map<String, dynamic> json) {
    final address = json['address'] ?? {};

    return Facility(
      id: json['id'] ,
      name: json['name'] ,
      type: _parseType(json['type']),
      street: address['street'],
      city: address['city'],
      state: address['state'],
      country: address['country'],
      zipCode: address['zipCode'],
      fullAddress:
          '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['country'] ?? ''} ${address['zipCode'] ?? ''}',
           gpsLatitude: json['gpsLatitude'],
      gpsLongitude: json['gpsLongitude'],
    );
  }

  /// ------------------------
  /// Convert back to JSON
  /// ------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': {
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        'zipCode': zipCode,
        'fullAddress': fullAddress,
      },
      'GPSLatitude': gpsLatitude,
      'GPSLongitude': gpsLongitude,
    };
  }

  /// ------------------------
  /// Helper: convert string or int type to int safely
  /// ------------------------
  static int? _parseType(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
