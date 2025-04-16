import 'package:dztrainfay/models/location.dart';
class Station {
  final String id;
  final String name;
  final Coordinates location;
  final String? lineId;

  Station({
    required this.id,
    required this.name,
    required this.location,
    this.lineId,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      location: Coordinates.fromJson(json['location'] as Map<String, dynamic>),
      lineId: json['lineId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'lineId': lineId,
    };
  }

  // Méthodes pour Firestore
  factory Station.fromFirestore(Map<String, dynamic> data) {
    return Station(
      id: data['id'] as String,
      name: data['name'] as String,
      location: Coordinates(
        lat: (data['latitude'] as num).toDouble(),
        lng: (data['longitude'] as num).toDouble(),
      ),
      lineId: data['lineId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'latitude': location.lat,
      'longitude': location.lng,
      'lineId': lineId,
    };
  }
}
