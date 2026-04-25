import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/model/journal_entry_model.dart';
import 'package:geocoding/geocoding.dart';

class HomeViewModel extends ChangeNotifier {
  final AppDatabase _db;

  HomeViewModel(this._db);

  GoogleMapController? mapController;
  bool locationPermissionGranted = false;
  LatLng currentMapCenter = const LatLng(37.7749, -122.4194);

  static const initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  Future<void> init() async {
    await _initLocation();
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
      locationPermissionGranted = true;
      notifyListeners();
      await moveToUserLocation();
    }
  }

  Future<void> moveToUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final userLatLng = LatLng(position.latitude, position.longitude);
      currentMapCenter = userLatLng;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 14),
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Could not get current position: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (locationPermissionGranted) {
      moveToUserLocation();
    }
  }

  void onCameraMove(CameraPosition position) {
    currentMapCenter = position.target;
  }

  Future<String> getLocationName() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        currentMapCenter.latitude,
        currentMapCenter.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.name,
          place.street,
          place.thoroughfare,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((p) => p != null && p.isNotEmpty).toSet().toList();
        return parts.join(', ');
      }
    } catch (e) {
      debugPrint('Could not get location name: $e');
    }
    return 'Unknown location';
  }

  Future<void> saveEntry(JournalEntryModel entry) async {
    await _db
        .into(_db.journalEntries)
        .insert(
          JournalEntriesCompanion.insert(
            entryId: entry.entryId,
            title: entry.title,
            body: entry.body,
            latitude: entry.latitude,
            longitude: entry.longitude,
            locationName: entry.locationName,
            imagePaths: entry.imagePaths.toString(),
            audioPaths: entry.audioPaths.toString(),
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
        );
  }
}
