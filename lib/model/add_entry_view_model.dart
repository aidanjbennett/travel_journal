import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_journal/model/journal_entry_model.dart';
import 'package:logger/logger.dart';

class AddEntryViewModel extends ChangeNotifier {
  final double initialLatitude;
  final double initialLongitude;
  final String locationName;

  AddEntryViewModel({
    required this.initialLatitude,
    required this.initialLongitude,
    required this.locationName,
  }) {
    _initRecorder();
  }

  // Controllers
  final titleController = TextEditingController();
  final textController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // Media
  final List<String> _imagePaths = [];
  final List<String> _audioPaths = [];

  List<String> get imagePaths => List.unmodifiable(_imagePaths);
  List<String> get audioPaths => List.unmodifiable(_audioPaths);

  // Recorder
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _isRecording;
  Duration get recordingDuration => _recordingDuration;

  // UI State
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> _initRecorder() async {
    _recorder.setLogLevel(Level.off);
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    _recorderReady = true;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<bool> ensureMicPermission() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
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
      bool hasPermission = await ensureMicPermission();

      if (!hasPermission) {
        if (kDebugMode) {
          print("Mic permission not granted");
        }
        return;
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

    if (_isRecording) {
      await toggleRecording();
    }

    _isSaving = true;
    notifyListeners();

    final now = DateTime.now();

    final entry = JournalEntryModel(
      title: titleController.text.trim(),
      body: textController.text.trim(),
      latitude: initialLatitude,
      longitude: initialLongitude,
      locationName: locationName,
      imagePaths: List.unmodifiable(_imagePaths),
      audioPaths: List.unmodifiable(_audioPaths),
      createdAt: now,
      updatedAt: now,
    );

    _isSaving = false;
    notifyListeners();

    return entry;
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
