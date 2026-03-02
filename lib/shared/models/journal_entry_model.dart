import 'package:uuid/uuid.dart';

final myUUID = Uuid();

class JournalEntry {
  final String entryId;

  // Entries will include array of images
  // and audio files but focusing on text for now
  final String title;
  final String text;

  // Map
  final double latitude;
  final double longitude;

  // Dates
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.title,
    required this.text,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  }) : entryId = myUUID.v4();

  // maybe set getters / setters
}
