import 'package:flutter/material.dart';
import 'package:dztrainfay/models/station.dart';

class StationsList extends StatelessWidget {
  final List<Station> stations;
  final String origin;
  final String destination;

  const StationsList({
    Key? key,
    required this.stations,
    required this.origin,
    required this.destination,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.train, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Itinéraire en Train',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRouteTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(BuildContext context) {
    return Column(
      children: [
        // Origine
        _buildTimelineItem(
          context,
          title: origin,
          subtitle: 'Départ',
          isFirst: true,
          isLast: false,
          isStation: false,
          color: Colors.green,
        ),

        // Stations
        ...stations.asMap().entries.map((entry) {
          final index = entry.key;
          final station = entry.value;

          String subtitle = 'Station ${index + 1}';
          if (index == 0) {
            subtitle = 'Première gare';
          } else if (index == stations.length - 1) {
            subtitle = 'Dernière gare';
          }

          return _buildTimelineItem(
            context,
            title: station.name,
            subtitle: subtitle,
            isFirst: false,
            isLast: false,
            isStation: true,
          );
        }).toList(),

        // Destination
        _buildTimelineItem(
          context,
          title: destination,
          subtitle: 'Arrivée',
          isFirst: false,
          isLast: true,
          isStation: false,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required bool isFirst,
        required bool isLast,
        required bool isStation,
        Color? color,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? Theme.of(context).primaryColor,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (isStation) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Gare',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
