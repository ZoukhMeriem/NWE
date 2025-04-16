import 'package:dztrainfay/models/location.dart';
import 'package:dztrainfay/models/station.dart';

class TrainRoute {
  final Location origin;
  final Location destination;
  final List<Station> stations;
  final double distance;
  final int duration;

  TrainRoute({
    required this.origin,
    required this.destination,
    required this.stations,
    required this.distance,
    required this.duration,
  });

  factory TrainRoute.fromJson(Map<String, dynamic> json) {
    return TrainRoute(
      origin: Location.fromJson(json['origin'] as Map<String, dynamic>),
      destination: Location.fromJson(json['destination'] as Map<String, dynamic>),
      stations: (json['stations'] as List)
          .map((e) => Station.fromJson(e as Map<String, dynamic>))
          .toList(),
      distance: (json['distance'] as num).toDouble(), // ✅ Assure que c'est bien un double
      duration: (json['duration'] as num).toInt(),    // ✅ Assure que c'est bien un int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'stations': stations.map((e) => e.toJson()).toList(),
      'distance': distance,
      'duration': duration,
    };
  }
}
