/*import 'package:flutter/material.dart';
import 'package:dztrainfay/models/location.dart';
import 'package:dztrainfay/services/route_service.dart';

class RouteSearch extends StatefulWidget {
 final Function(Location, Location) onSearch;
  final bool isLoading;
  final RouteService routeService;

  const RouteSearch({
    Key? key,
    required this.onSearch,
    required this.isLoading,
    required this.routeService,
  }) : super(key: key);

  @override
  State<RouteSearch> createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _isGeocoding = false;
  String? _error;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final originAddress = _originController.text.trim();
    final destinationAddress = _destinationController.text.trim();

    if (originAddress.isEmpty || destinationAddress.isEmpty) {
      setState(() {
        _error = "Veuillez renseigner l'origine et la destination";
      });
      return;
    }

    try {
      setState(() {
        _isGeocoding = true;
        _error = null;
      });

      // Convertir les adresses en coordonnées
      final origin = await widget.routeService.geocodeAddress(originAddress);
      final destination = await widget.routeService.geocodeAddress(destinationAddress);

      widget.onSearch(origin, destination);
    } catch (err) {
      setState(() {
        _error = "Une erreur s'est produite lors de la recherche d'itinéraire";
      });
      print(err);
    } finally {
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOriginField(),
            const SizedBox(height: 16),
            _buildDestinationField(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginField() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _originController,
            decoration: const InputDecoration(
              labelText: 'Départ',
              hintText: 'Adresse de départ',
              border: OutlineInputBorder(),
            ),
            enabled: !widget.isLoading && !_isGeocoding,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationField() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          child: const Icon(
            Icons.location_on,
            size: 24,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              labelText: 'Arrivée',
              hintText: 'Adresse d\'arrivée',
              border: OutlineInputBorder(),
            ),
            enabled: !widget.isLoading && !_isGeocoding,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (widget.isLoading || _isGeocoding) ? null : _handleSearch,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: (widget.isLoading || _isGeocoding)
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search),
            SizedBox(width: 8),
            Text('Rechercher'),
          ],
        ),
      ),
    );
  }*/

