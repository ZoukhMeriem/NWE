import 'package:flutter/material.dart';
import 'package:dztrainfay/models/route.dart';
import 'package:dztrainfay/models/station.dart';

class MapView extends StatelessWidget {
  final TrainRoute route;

  const MapView({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("📍 Itinéraire récupéré :");
    print("- Départ: ${route.origin.coordinates.lat}, ${route.origin.coordinates.lng}");
    for (var station in route.stations) {
      print("- Station: ${station.name} (${station.location.lat}, ${station.location.lng})");
    }
    print("- Arrivée: ${route.destination.coordinates.lat}, ${route.destination.coordinates.lng}");


    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: MapPainter(route: route),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildMapContent(constraints.maxWidth, constraints.maxHeight);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent(double width, double height) {
    return Stack(
      children: [
        // Origine (départ)
        _buildMapPoint(
          route.origin.coordinates.lat,
          route.origin.coordinates.lng,
          Colors.green,
          'Départ',
          width,
          height,
        ),

        // Stations
        ...route.stations.map((station) => _buildMapPoint(
          station.location.lat,
          station.location.lng,
          Colors.blue,
          station.name,
          width,
          height,
          isStation: true,
        )),

        // Destination (arrivée)
        _buildMapPoint(
          route.destination.coordinates.lat,
          route.destination.coordinates.lng,
          Colors.red,
          'Arrivée',
          width,
          height,
        ),
      ],
    );
  }

  Widget _buildMapPoint(double lat, double lng, Color color, String label, double width, double height, {bool isStation = false}) {
    final allLats = route.stations.map((s) => s.location.lat).toList()
      ..add(route.origin.coordinates.lat)
      ..add(route.destination.coordinates.lat);

    final allLngs = route.stations.map((s) => s.location.lng).toList()
      ..add(route.origin.coordinates.lng)
      ..add(route.destination.coordinates.lng);

    final minLat = allLats.reduce((a, b) => a < b ? a : b);
    final maxLat = allLats.reduce((a, b) => a > b ? a : b);
    final minLng = allLngs.reduce((a, b) => a < b ? a : b);
    final maxLng = allLngs.reduce((a, b) => a > b ? a : b);

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    const padding = 0.2; // 20% padding

    final left = ((lng - (minLng - lngRange * padding)) /
        ((maxLng + lngRange * padding) - (minLng - lngRange * padding))) *
        width;

    final top = (1 - (lat - (minLat - latRange * padding)) /
        ((maxLat + latRange * padding) - (minLat - latRange * padding))) *
        height;
    if (left.isNaN || top.isNaN) return SizedBox();

    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          if (!isStation)
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                backgroundColor: Colors.white.withOpacity(0.7),
              ),
            ),
          Container(
            width: isStation ? 8 : 12,
            height: isStation ? 8 : 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final TrainRoute route;

  MapPainter({required this.route});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    final allLats = route.stations.map((s) => s.location.lat).toList()
      ..add(route.origin.coordinates.lat)
      ..add(route.destination.coordinates.lat);

    final allLngs = route.stations.map((s) => s.location.lng).toList()
      ..add(route.origin.coordinates.lng)
      ..add(route.destination.coordinates.lng);

    final minLat = allLats.reduce((a, b) => a < b ? a : b);
    final maxLat = allLats.reduce((a, b) => a > b ? a : b);
    final minLng = allLngs.reduce((a, b) => a < b ? a : b);
    final maxLng = allLngs.reduce((a, b) => a > b ? a : b);

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    const padding = 0.2; // 20% padding

    double toPixelX(double lng) {
      return ((lng - (minLng - lngRange * padding)) /
          ((maxLng + lngRange * padding) - (minLng - lngRange * padding))) *
          size.width;
    }

    double toPixelY(double lat) {
      return (1 - (lat - (minLat - latRange * padding)) /
          ((maxLat + latRange * padding) - (minLat - latRange * padding))) *
          size.height;
    }

    path.moveTo(
      toPixelX(route.origin.coordinates.lng),
      toPixelY(route.origin.coordinates.lat),
    );

    for (final station in route.stations) {
      path.lineTo(
        toPixelX(station.location.lng),
        toPixelY(station.location.lat),
      );
    }

    path.lineTo(
      toPixelX(route.destination.coordinates.lng),
      toPixelY(route.destination.coordinates.lat),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
