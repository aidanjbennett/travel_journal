import 'package:uuid/uuid.dart';

final myUUID = Uuid();

class JournalEntry {
  final String entryId;

  // Data
  final String title;
  final String text;
  final List<String> imagePaths;

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
    this.imagePaths = const [],
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    required this.updatedAt,
  }) : entryId = myUUID.v4();
}
