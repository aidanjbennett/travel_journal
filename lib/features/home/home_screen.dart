import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/features/add_entry/add_entry_screen.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';
import 'package:travel_journal/shared/widgets/main_navbar_widget.dart';
import 'package:travel_journal/shared/widgets/main_title_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  bool _locationPermissionGranted = false;

  LatLng _currentMapCenter = const LatLng(37.7749, -122.4194);

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() => _locationPermissionGranted = true);

      _moveToUserLocation();
    }
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.name,
          place.locality,
          place.administrativeArea,
        ].where((p) => p != null && p.isNotEmpty).toList();
        return parts.join(', ');
      }
    } catch (e) {
      debugPrint('Could not get location name: $e');
    }
    return 'Unknown location';
  }

  Future<void> _openCreateEntry() async {
    final locationName = await _getLocationName(
      _currentMapCenter.latitude,
      _currentMapCenter.longitude,
    );

    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddEntryScreen(
          locationName: locationName,
          initialLatitude: _currentMapCenter.latitude,
          initialLongitude: _currentMapCenter.longitude,
        ),
      ),
    );

    if (entry != null && mounted) {
      context.read<JournalStore>().addEntry(entry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entry "${entry.title}" saved!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _moveToUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      _currentMapCenter = userLatLng;
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 14),
        ),
      );
    } catch (e) {
      debugPrint('Could not get current position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MainTitleWidget(),
        actions: [
          IconButton(
            tooltip: 'New journal entry',
            icon: const Icon(Icons.add),
            onPressed: _openCreateEntry,
          ),
        ],
      ),
      bottomNavigationBar: MainNavbar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MapView(
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: (controller) {
                  _mapController = controller;

                  if (_locationPermissionGranted) {
                    _moveToUserLocation();
                  }
                },
                onCameraMove: (position) {
                  _currentMapCenter = position.target;
                },
                locationPermissionGranted: _locationPermissionGranted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({
    required this.initialCameraPosition,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.locationPermissionGranted,
  });

  final CameraPosition initialCameraPosition;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(CameraPosition) onCameraMove;
  final bool locationPermissionGranted;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      myLocationEnabled: locationPermissionGranted,
      myLocationButtonEnabled: locationPermissionGranted,
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
    );
  }
}
