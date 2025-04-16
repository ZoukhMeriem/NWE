import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dztrainfay/models/station.dart';

import '../models/location.dart';
import '../models/route.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String>? _cachedLines;
  final Map<String, List<Station>> _cachedStations = {};

  // Base de données simulée des stations (utilisée comme fallback)
  final List<Station> _stations = [
    Station(
      id: "alger",
      name: "Gare d'Alger",
      location: Coordinates(lat: 36.7525, lng: 3.0420),
      lineId: "ligne_3",
    ),
    Station(
      id: "agha",
      name: "Gare d'Agha",
      location: Coordinates(lat: 36.7649, lng:3.0535),
      lineId: "ligne_3",
    ),
    Station(
      id: "ateliers",
      name: "Gare des Ateliers",
      location: Coordinates(lat: 36.7623, lng: 3.0712),
      lineId: "ligne_3",
    ),
    Station(
      id: "hussein-dey",
      name: "Gare de Hussein Dey",
      location: Coordinates(lat: 36.7481, lng:3.0866)
      ,
      lineId: "ligne_3",
    ),
    Station(
      id: "caroubier",
      name: "Gare du Caroubier",
      location: Coordinates(lat: 36.7353, lng:3.1194),
      lineId: "ligne_3",
    ),
    Station(
      id: "el-harrach",
      name: "Gare d'El Harrach",
      location: Coordinates(lat: 36.7131, lng: 3.1529),
      lineId: "ligne_3",
    ),
    Station(
      id: "gué-de-cne",
      name: "Gare du Gué de Cne",
      location: Coordinates(lat: 36.6969, lng: 3.09493),
      lineId: "ligne_3",
    ),
    Station(
      id: "ain-naadja",
      name: "Gare de Ain Naadja",
      location: Coordinates(lat: 36.713602, lng: 3.0868),
      lineId: "ligne_3",
    ),
    Station(
      id: "baba-ali",
      name: "Gare de Baba Ali",
      location: Coordinates(lat: 36.6667, lng: 2.9592),
      lineId: "ligne_3",
    ),
    Station(
      id: "birtouta",
      name: "Gare de Birtouta",
      location: Coordinates(lat: 36.6372,  lng: 2.9597),
      lineId: "ligne_3",
    ),
    Station(
      id: "boufarik",
      name: "Gare de Boufarik",
      location: Coordinates(lat: 36.57413, lng: 2.91214),
      lineId: "ligne_3",
    ),
    Station(
      id: "beni-mered",
      name: "Gare de Beni Mered",
      location: Coordinates(lat: 36.5233, lng: 2.8585),
      lineId: "ligne_3",
    ),
    Station(
      id: "blida",
      name: "Gare de Blida",
      location: Coordinates(lat: 36.4808, lng: 2.8296),
      lineId: "ligne_3",
    ),
    Station(
      id: "chiffa",
      name: "Gare de Chiffa",
      location: Coordinates(lat: 36.4464, lng: 2.7512),
      lineId: "ligne_3",
    ),
    Station(
      id: "mouzaia",
      name: "Gare de Mouzaia",
      location: Coordinates(lat: 36.4667, lng: 2.7052),
      lineId: "ligne_3",
    ),
    Station(
      id: "el-affroun",
      name: "Gare d'El Affroun",
      location: Coordinates(lat: 36.4664, lng: 2.6251),
      lineId: "ligne_3",
    ),


    Station(
      id: "alger",
      name: "Gare d'Alger",
      location: Coordinates(lat: 36.7525, lng: 3.0420),
      lineId: "ligne_2",
    ),
    Station(
      id: "agha",
      name: "Gare d'Agha",
      location: Coordinates(lat: 36.7649, lng:3.0535),
      lineId: "ligne_2",
    ),
    Station(
      id: "ateliers",
      name: "Gare des Ateliers",
      location: Coordinates(lat: 36.7623, lng: 3.0712),
      lineId: "ligne_2",
    ),
    Station(
      id: "hussein-dey",
      name: "Gare de Hussein Dey",
      location: Coordinates(lat: 36.7481, lng:3.0866),
      lineId: "ligne_2",
    ),
    Station(
      id: "caroubier",
      name: "Gare du Caroubier",
      location: Coordinates(lat: 36.7353, lng:3.1194),
      lineId: "ligne_2",
    ),
    Station(
      id: "el-harrach",
      name: "Gare d'El Harrach",
      location: Coordinates(lat: 36.7131, lng: 3.1529),
      lineId: "ligne_2",
    ),
    Station(
      id: "ouedsmar",
      name: "Gare de Oued Smar",
      location: Coordinates(lat:  36.70384, lng: 3.17187),
      lineId: "ligne_2",
    ),
    Station(
      id: "babezzouar",
      name: "Gare de Bab Ezzouar",
      location: Coordinates(lat: 36.7223, lng: 3.1865),
      lineId: "ligne_2",
    ),
    Station(
      id: "dar-el-beida",
      name: "Gare de Dar El Beida",
      location: Coordinates(lat: 36.7174, lng: 3.2121),
      lineId: "ligne_2",
    ),
    Station(
      id: "rouiba",
      name: "Gare de Rouiba",
      location: Coordinates(lat: 36.7342, lng:  3.2828),
      lineId: "ligne_2",
    ),
    Station(
      id: "rouibaind",
      name: "Gare de Rouiba Ind",
      location: Coordinates(lat: 36.7342, lng:  3.2828),
      lineId: "ligne_2",
    ),
    Station(
      id: "reghaia",
      name: "Gare de Reghaia",
      location: Coordinates(lat:36.7364, lng:3.3311),
      lineId: "ligne_2",
    ),
    Station(
      id: "reghaiaind",
      name: "Gare de Reghaia Ind",
      location: Coordinates(lat:36.7364, lng:3.3311),
      lineId: "ligne_2",
    ),
    Station(
      id: "boudouaou",
      name: "Gare de Boudouaou",
      location: Coordinates(lat:36.7403, lng:3.4128),
      lineId: "ligne_2",
    ),Station(
      id: "corso",
      name: "Gare de Corso",
      location: Coordinates(lat: 36.7539, lng: 3.4356),
      lineId: "ligne_2",
    ),
    Station(
      id: "boumerdes",
      name: "Gare de Boumerdes",
      location: Coordinates(lat: 36.7533, lng: 3.4742),
      lineId: "ligne_2",
    ),
    Station(
      id: "tidjelabine",
      name: "Gare de Tidjelabine",
      location: Coordinates(lat: 36.7314, lng: 3.5011),
      lineId: "ligne_2",
    ),
    Station(
      id: "thenia",
      name: "Gare de Thenia",
      location: Coordinates(lat: 36.7361, lng:3.6036),
      lineId: "ligne_2",
    ),






    Station(
      id: "agha",
      name: "Gare d'Agha",
      location: Coordinates(lat: 36.7649, lng:3.0535),
      lineId: "ligne_1",
    ),
    Station(
      id: "ateliers",
      name: "Gare des Ateliers",
      location: Coordinates(lat: 36.7623, lng: 3.0712),
      lineId: "ligne_1",
    ),
    Station(
      id: "hussein-dey",
      name: "Gare de Hussein Dey",
      location: Coordinates(lat: 36.7481, lng:3.0866),
      lineId: "ligne_1",
    ),
    Station(
      id: "caroubier",
      name: "Gare du Caroubier",
      location: Coordinates(lat: 36.7353, lng:3.1194),
      lineId: "ligne_1",
    ),
    Station(
      id: "el-harrach",
      name: "Gare d'El Harrach",
      location: Coordinates(lat: 36.7131, lng: 3.1529),
      lineId: "ligne_1",
    ),
    Station(
      id: "gué-de-cne",
      name: "Gare du Gué de Cne",
      location: Coordinates(lat: 36.6969, lng: 3.09493),
      lineId: "ligne_1",
    ),
    Station(
      id: "ain-naadja",
      name: "Gare de Ain Naadja",
      location: Coordinates(lat: 36.713602, lng: 3.0868),
      lineId: "ligne_1",
    ),
    Station(
      id: "baba-ali",
      name: "Gare de Baba Ali",
      location: Coordinates(lat: 36.6667, lng: 2.9592),
      lineId: "ligne_1",
    ),
    Station(
      id: "birtouta",
      name: "Gare de Birtouta",
      location: Coordinates(lat: 36.6372,  lng: 2.9597),
      lineId: "ligne_1",

    ),
    Station(
      id: "tessala-el-merdja",
      name: "Gare de Tessala El Merdja",
      location: Coordinates(lat:36.639515, lng: 2.935544),
      lineId: "ligne_1",

    ),
    Station(
      id: "sidi-abde-allah",
      name: "Gare de Sidi Abde Allah",
      location: Coordinates(lat:36.6802202, lng: 2.8921599),
      lineId: "ligne_1",

    ),
    Station(
      id: "sidi-abde-allah-univ",
      name: "Gare de Sidi Abde Allah Univ",
      location: Coordinates(lat:36.6802202, lng: 2.8921599),
      lineId: "ligne_1",

    ),
    Station(
      id: "zeralda",
      name: "Gare de Zeralda",
      location: Coordinates(lat: 36.7111,  lng: 2.8425),
      lineId: "ligne_1",

    ),



    Station(
      id: "agha",
      name: "Gare d'Agha",
      location: Coordinates(lat: 36.7649, lng:3.0535),
      lineId: "ligne_4",
    ),
    Station(
      id: "el-harrach",
      name: "Gare d'El Harrach",
      location: Coordinates(lat: 36.7131, lng: 3.1529),
      lineId: "ligne_4",
    ),
    Station(
      id: "babezzouar",
      name: "Gare de Bab Ezzouar",
      location: Coordinates(lat: 36.7223, lng: 3.1865),
      lineId: "ligne_4",
    ),
    Station(
      id: "aeroport-houari",
      name: "Gare de  l'Aéroport Houari Boumédiène",
      location: Coordinates(lat: 36.6910, lng: 3.2154),
      lineId: "ligne_4",
    ),

  ];

  // Méthode pour tester la connexion à Firestore
  Future<void> testFirestore() async {
    try {
      await _firestore.collection('test').doc('test').set({'test': 'test'});
      print('✅ Connexion à Firestore réussie');
    } catch (e) {
      print('🚨 Erreur de connexion à Firestore: $e');
    }
  }

  // Récupérer toutes les lignes de train
  Future<List<String>> getAllLines() async {
    if (_cachedLines != null) return _cachedLines!;
    try {
      final snapshot = await _firestore.collection('lignes').get();
      List<String> lignes = snapshot.docs.map((doc) => doc.id).toList();
      print("🚆 Lignes disponibles : $_cachedLines");

      return lignes;
    } catch (e) {
      print('🚨 Erreur lors de la récupération des lignes: $e');
      // Fallback vers les données locales
      return ['ligne_1', 'ligne_2', 'ligne_3', 'ligne_4']; // 🔥 Fallback vers des valeurs par défaut
    }
  }

  // Récupérer les gares pour une ligne donnée
  Future<List<Station>> getGaresForLine(String lineId) async {

    if (_cachedStations.containsKey(lineId)) {

      return _cachedStations[lineId]!; // ⚡ Utilisation du cache
    }
    try {

      final snapshot = await _firestore
          .collection(' Gares')
          .where('lineId', isEqualTo: lineId)
          .orderBy('ordre')
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ Aucune gare trouvée pour la ligne $lineId dans Firestore, utilisation des données locales');
        return _stations.where((station) => station.lineId == lineId).toList();
      }

      List<Station> stations = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();

        return Station.fromFirestore(data);
      }).toList();
      _cachedStations[lineId] = stations;
      return stations;
    } catch (e) {
      print('🚨 Erreur lors de la récupération des gares: $e');

      // Fallback vers les données locales
      return _stations.where((station) => station.lineId == lineId).toList();
    }

  }

  // Calcule l'itinéraire entre deux points
  Future<TrainRoute> calculateRoute(Location origin, Location destination) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // Trouver les stations les plus proches de l'origine et de la destination
    Station closestToOrigin = await _findClosestStation(origin.coordinates);
    Station closestToDestination = await _findClosestStation(destination.coordinates);
    TrainRoute route;

    // Si les deux stations sont sur la même ligne, c'est simple
    if (closestToOrigin.lineId == closestToDestination.lineId) {
      return await _calculateDirectRoute(closestToOrigin, closestToDestination, origin, destination);
    } else {
      // Sinon, il faut trouver un point de transfert
      return await _calculateRouteWithTransfer(closestToOrigin, closestToDestination, origin, destination);
    }

  }

  // Calcule un itinéraire direct (même ligne)
  Future<TrainRoute> _calculateDirectRoute(
      Station originStation,
      Station destinationStation,
      Location origin,
      Location destination) async {

    final allStations = await getGaresForLine(originStation.lineId!);

    // Trouver les indices des stations dans la liste
    int originIndex = allStations.indexWhere((s) => s.id == originStation.id);
    int destinationIndex = allStations.indexWhere((s) => s.id == destinationStation.id);

    // S'assurer d'obtenir les stations dans le bon ordre
    int startIndex = min(originIndex, destinationIndex);
    int endIndex = max(originIndex, destinationIndex);

    // Obtenir toutes les stations entre les deux points
    List<Station> routeStations = allStations.sublist(startIndex, endIndex + 1);

    // Calculer la distance et la durée
    double distance = _calculateTotalDistance(routeStations);
    int duration = (distance * 3).round(); // Estimation: 3 minutes par km

    // Si la direction est inversée, inverser la liste des stations
    final List<Station> finalStations =
    originIndex > destinationIndex ? routeStations.reversed.toList() : routeStations;

    return TrainRoute(
      origin: origin,
      destination: destination,
      stations: finalStations,
      distance: distance,
      duration: duration,
    );
  }

  // Calcule un itinéraire avec transfert (lignes différentes)
  Future<TrainRoute> _calculateRouteWithTransfer(
      Station originStation,
      Station destinationStation,
      Location origin,
      Location destination) async {

    // Pour simplifier, on suppose qu'il existe toujours un transfert entre deux lignes
    // Dans une application réelle, il faudrait une logique plus complexe pour les transferts

    // Simuler un itinéraire avec transfert (ici très simplifié)
    final originLineStations = await getGaresForLine(originStation.lineId!);
    final destinationLineStations = await getGaresForLine(destinationStation.lineId!);

    // On prend la dernière station de la ligne d'origine comme point de transfert
    Station transferStation = originLineStations.last;

    // On crée un itinéraire combiné
    List<Station> routeStations = [
      ...originLineStations.takeWhile((s) => s.id != transferStation.id),
      transferStation,
      ...destinationLineStations.skipWhile((s) => s.id != transferStation.id).skip(1),
    ];

    // Calculer la distance et la durée
    double distance = _calculateTotalDistance(routeStations);
    int duration = (distance * 3).round() + 10; // +10 min pour le transfert

    return TrainRoute(
      origin: origin,
      destination: destination,
      stations: routeStations,
      distance: distance,
      duration: duration,
    );
  }

//Trouver la station la plus proche (avec toutes les lignes)
  Future<List<Station>> getAllStations() async {
    List<String> lines = await getAllLines(); // Récupérer toutes les lignes
    List<Station> allStations = [];

    for (String line in lines) {
      final stations = await getGaresForLine(line);
      allStations.addAll(stations);
    }

    return allStations;
  }

  // Trouver la station la plus proche des coordonnées données
  Future<Station> _findClosestStation(Coordinates coordinates) async {
    List<Station> allStations = await getAllStations();

    return allStations.reduce((closest, station) {
      double distance = _calculateDistance(
        coordinates.lat, coordinates.lng,
        station.location.lat, station.location.lng,
      );

      double closestDistance = _calculateDistance(
        coordinates.lat, coordinates.lng,
        closest.location.lat, closest.location.lng,
      );

      return distance < closestDistance ? station : closest;
    });
  }


  // Calculer la distance entre deux points en utilisant la formule de Haversine
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371; // Rayon de la Terre en km
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a =
        sin(dLat/2) * sin(dLat/2) +
            cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
                sin(dLng/2) * sin(dLng/2);

    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = R * c; // Distance en km

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  // Calculer la distance totale d'un itinéraire
  double _calculateTotalDistance(List<Station> routeStations) {
    double totalDistance = 0;

    for (int i = 0; i < routeStations.length - 1; i++) {
      Station currentStation = routeStations[i];
      Station nextStation = routeStations[i + 1];

      totalDistance += _calculateDistance(
        currentStation.location.lat,
        currentStation.location.lng,
        nextStation.location.lat,
        nextStation.location.lng,
      );
    }

    return double.parse(totalDistance.toStringAsFixed(2));
  }

  // Convertir une adresse en coordonnées (géocodage)
  Future<Location> geocodeAddress(String address) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Pour les besoins de la démo, on utilise des coordonnées fixes
    Map<String, Coordinates> mockLocations = {
      "alger": Coordinates(lat: 36.7538, lng: 3.0588),
      "agha": Coordinates(lat: 36.7580, lng: 3.0580),
      "hussein dey": Coordinates(lat: 36.7481, lng:3.0866),
      "el harrach": Coordinates(lat: 36.7131, lng: 3.1529),
      "bab ezzouar": Coordinates(lat: 36.7223, lng: 3.1865),
      "dar el beida": Coordinates(lat: 36.7174, lng: 3.2121),
      "Aéroport Houari Boumédièn": Coordinates(lat: 36.6910, lng:  3.215474),
      "ain naadja": Coordinates(lat: 36.7136, lng: 3.0867),
      "ateliers":Coordinates(lat:36.7481, lng: 3.0866),
      "baba ali":Coordinates(lat:36.6667,lng:  2.9592),
      "beni mered":Coordinates(lat:36.5233, lng: 2.8585),
      "birtouta":Coordinates(lat:36.6372, lng: 2.9597),
      "blida":Coordinates(lat:36.4808, lng: 2.8296),
      "bordj menaiel":Coordinates(lat:36.7489, lng: 3.7231),
      "boufarik":Coordinates(lat: 36.57413, lng: 2.91214),
      "boumerdes":Coordinates(lat: 36.7533, lng: 3.4742),
      "caroubier":Coordinates(lat:36.7481, lng: 3.0866),
      "gue de cne":Coordinates(lat: 36.6969, lng: 3.09493),
      "thenia":Coordinates(lat: 36.7361, lng:3.6036),
      "caroubier":Coordinates(lat: 36.7252154, lng:3.5527097),
      "oued smar":Coordinates(lat:  36.70384, lng: 3.17187),
      "rouiba":Coordinates(lat: 36.7342, lng:  3.2828),
      "reghaia ind":Coordinates(lat:36.7364, lng:3.3311),
      "boudouaou":Coordinates(lat:36.7403, lng:3.4128),
      "corso":Coordinates(lat: 36.7539, lng: 3.4356),
      "tidjelabine":Coordinates(lat: 36.7314, lng: 3.5011),
    };

    // Normaliser l'adresse
    String normalizedAddress = address.toLowerCase().trim();

    // Essayer de trouver une correspondance exacte
    if (mockLocations.containsKey(normalizedAddress)) {
      return Location(
        address: address,
        coordinates: mockLocations[normalizedAddress]!,
      );
    }

    // Essayer de trouver une correspondance partielle
    for (final entry in mockLocations.entries) {
      if (normalizedAddress.contains(entry.key)) {
        return Location(
          address: address,
          coordinates: entry.value,
        );
      }
    }

    // Si aucune correspondance n'est trouvée, retourner des coordonnées par défaut
    final random = Random();
    return Location(
      address: address,
      coordinates: Coordinates(
        lat: 36.7538 + (random.nextDouble() * 0.02 - 0.01),
        lng: 3.0588 + (random.nextDouble() * 0.02 - 0.01),
      ),
    );
  }
}
