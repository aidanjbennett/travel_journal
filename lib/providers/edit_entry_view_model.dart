import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_journal/database/app_database.dart';
import 'package:travel_journal/model/journal_entry_model.dart';
import 'package:logger/logger.dart';

class EditEntryViewModel extends ChangeNotifier {
  final JournalEntryModel original;
  final AppDatabase _db;

  EditEntryViewModel({required this.original, required AppDatabase db})
    : _db = db {
    titleController = TextEditingController(text: original.title);
    textController = TextEditingController(text: original.body);
    _imagePaths = List.of(original.imagePaths);
    _audioPaths = List.of(original.audioPaths);
    _initRecorder();
  }

  // Controllers
  late final TextEditingController titleController;
  late final TextEditingController textController;

  final ImagePicker _picker = ImagePicker();

  // Media
  late List<String> _imagePaths;
  late List<String> _audioPaths;

  List<String> get imagePaths => List.unmodifiable(_imagePaths);
  List<String> get audioPaths => List.unmodifiable(_audioPaths);

  // Recorder
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  bool _recorderOpened = false;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _isRecording;
  Duration get recordingDuration => _recordingDuration;

  // UI state
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> _initRecorder() async {
    _recorder.setLogLevel(Level.off);
    _recorderReady = true;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    if (_recorderOpened) _recorder.closeRecorder();
    super.dispose();
  }

  Future<bool> ensureMicPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.microphone.status;
      if (status.isDenied) status = await Permission.microphone.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) await openAppSettings();
      return false;
    }
    return true;
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null) return;
    _imagePaths.add(file.path);
    notifyListeners();
  }

  void removeImage(int index) {
    _imagePaths.removeAt(index);
    notifyListeners();
  }

  Future<String> _buildAudioPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    return '${dir.path}/$filename';
  }

  Future<void> toggleRecording() async {
    if (!_recorderReady) return;

    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      _isRecording = false;
      _recordingDuration = Duration.zero;
      if (path != null) _audioPaths.add(path);
    } else {
      final hasPermission = await ensureMicPermission();
      if (!hasPermission) return;

      if (!_recorderOpened) {
        await _recorder.openRecorder();
        await _recorder.setSubscriptionDuration(
          const Duration(milliseconds: 500),
        );
        _recorderOpened = true;
      }

      final path = await _buildAudioPath();
      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);

      _recorder.onProgress?.listen((event) {
        _recordingDuration = event.duration;
        notifyListeners();
      });

      _isRecording = true;
    }

    notifyListeners();
  }

  void removeAudio(int index) {
    final path = _audioPaths[index];
    _audioPaths.removeAt(index);
    File(path).deleteSync();
    notifyListeners();
  }

  Future<JournalEntryModel?> save(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return null;

    if (_isRecording) await toggleRecording();

    _isSaving = true;
    notifyListeners();

    final updated = JournalEntryModel(
      entryId: original.entryId,
      title: titleController.text.trim(),
      body: textController.text.trim(),
      latitude: original.latitude,
      longitude: original.longitude,
      locationName: original.locationName,
      imagePaths: List.unmodifiable(_imagePaths),
      audioPaths: List.unmodifiable(_audioPaths),
      createdAt: original.createdAt,
      updatedAt: DateTime.now(),
    );

    await _db.updateEntry(updated);

    _isSaving = false;
    notifyListeners();

    return updated;
  }
}
