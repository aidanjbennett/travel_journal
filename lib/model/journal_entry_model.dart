import 'package:uuid/uuid.dart';

final myUUID = Uuid();

class JournalEntryModel {
  final String entryId;

  // Data
  final String title;
  final String body;
  final List<String> imagePaths;
  final List<String> audioPaths;

  // Map
  final double latitude;
  final double longitude;
  final String locationName;

  // Dates
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntryModel({
    String? entryId,
    required this.title,
    required this.body,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    required this.updatedAt,

    // Audio and images paths down here
    this.imagePaths = const [],
    this.audioPaths = const [],
  }) : entryId = entryId ?? myUUID.v4();
}
