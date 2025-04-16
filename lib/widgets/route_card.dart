import 'package:flutter/material.dart';
import 'package:dztrainfay/models/route.dart';

class RouteCard extends StatelessWidget {
  final TrainRoute route;

  const RouteCard({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.route, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${route.stations.length} stations',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildInfoItem(
                  context,
                  Icons.straighten,
                  '${route.distance} km',
                ),
                const SizedBox(width: 16),
                _buildInfoItem(
                  context,
                  Icons.access_time,
                  _formatDuration(route.duration),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }
}
