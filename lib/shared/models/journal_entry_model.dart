import 'package:uuid/uuid.dart';

final myUUID = Uuid();

class JournalEntry {
  final String entryId;

  // Data
  final String title;
  final String text;
  final List<String> imagePaths;
  final List<String> audioPaths;

  // Map
  final double latitude;
  final double longitude;
  final String locationName;

  // Dates
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.title,
    required this.text,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    required this.updatedAt,

    // Audio and images paths down here
    this.imagePaths = const [],
    this.audioPaths = const [],
  }) : entryId = myUUID.v4();
}
