// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:collection';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/medical_records_repository.dart';

enum MedicalRecordsStatus { initial, loading, loaded, empty, error }

class MedicalRecordsController extends ChangeNotifier {
  MedicalRecordsController({required MedicalRecordsRepository repository})
    : _repository = repository;

  static const int maxFileSizeBytes = 5242880; // 5 MiB
  static const Set<String> allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};

  final MedicalRecordsRepository _repository;

  UnmodifiableListView<MedicalRecord> _records =
      UnmodifiableListView<MedicalRecord>(const []);
  MedicalRecordsStatus _status = MedicalRecordsStatus.initial;
  bool _isUploading = false;
  bool _isDownloading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  UnmodifiableListView<MedicalRecord> get records => _records;
  MedicalRecordsStatus get status => _status;
  bool get isUploading => _isUploading;
  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == MedicalRecordsStatus.loading;
  bool get isLoaded => _status == MedicalRecordsStatus.loaded;
  bool get isEmpty => _status == MedicalRecordsStatus.empty;
  bool get hasError => _status == MedicalRecordsStatus.error;

  Future<void> loadRecords() async {
    _setStatus(MedicalRecordsStatus.loading, errorMessage: null);

    try {
      final result = await _repository.getMedicalRecords();
      if (_isDisposed) return;

      _records = UnmodifiableListView<MedicalRecord>(result);
      _setStatus(
        result.isEmpty
            ? MedicalRecordsStatus.empty
            : MedicalRecordsStatus.loaded,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      _debugLog('loadRecords failed', error, stackTrace);
      if (_isDisposed) return;
      _setStatus(
        MedicalRecordsStatus.error,
        errorMessage: 'Failed to load medical records.',
      );
    }
  }

  Future<bool> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required MedicalRecordPurpose purpose,
  }) async {
    if (_isUploading) return false;

    final validationError = validateFile(
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: bytes.lengthInBytes,
    );

    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setUploading(true);
    _clearError();

    try {
      final intent = await _repository.createUploadIntent(
        mimeType: mimeType,
        sizeBytes: bytes.lengthInBytes,
        purpose: purpose,
      );

      if (_isDisposed) return false;

      if (DateTime.now().isAfter(intent.uploadExpiresAt)) {
        _setError('Upload intent expired. Please try again.');
        return false;
      }

      await _repository.uploadToSignedUrl(
        uploadUrl: intent.uploadUrl,
        bucket: intent.bucket,
        objectPath: intent.objectPath,
        fileBytes: bytes,
        mimeType: mimeType,
        uploadExpiresAt: intent.uploadExpiresAt,
      );

      if (_isDisposed) return false;

      final confirmedRecord = await _repository.confirmUpload(
        intent.storedObjectId,
      );
      if (_isDisposed) return false;

      _records = UnmodifiableListView<MedicalRecord>([
        confirmedRecord,
        ..._records,
      ]);

      _setStatus(MedicalRecordsStatus.loaded, errorMessage: null);
      return true;
    } catch (error, stackTrace) {
      _debugLog('uploadBytes failed', error, stackTrace);
      if (_isDisposed) return false;
      _setError(error.toString().replaceAll('ApiException: ', ''));
      return false;
    } finally {
      _setUploading(false);
    }
  }

  Future<bool> pickAndUploadFile({
    required MedicalRecordPurpose purpose,
  }) async {
    if (_isUploading) return false;

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: allowedExtensions.toList(growable: false),
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = result.files.single;
      final fileName = file.name.trim();
      final Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        _setError('Could not read the selected file.');
        return false;
      }

      final mimeType = resolveMimeType(fileName);
      if (mimeType == null) {
        _setError('Unsupported file type. Only PDF, JPG, and PNG are allowed.');
        return false;
      }

      return await uploadBytes(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        purpose: purpose,
      );
    } catch (error, stackTrace) {
      _debugLog('pickAndUploadFile failed', error, stackTrace);
      if (_isDisposed) return false;
      _setError('File selection failed.');
      return false;
    }
  }

  Future<String?> fetchDownloadUrl(MedicalRecord record) async {
    if (!record.canDownload) {
      _setError('Download unavailable until security verification is PASSED.');
      return null;
    }

    if (_isDownloading) return null;
    _setDownloading(true);
    _clearError();

    try {
      final download = await _repository.getDownloadUrl(record.id);
      if (_isDisposed) return null;
      return download.downloadUrl;
    } catch (error, stackTrace) {
      _debugLog('fetchDownloadUrl failed', error, stackTrace);
      if (_isDisposed) return null;
      _setError('Download request denied or expired.');
      return null;
    } finally {
      _setDownloading(false);
    }
  }

  String? validateFile({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) {
    if (fileName.trim().isEmpty) {
      return 'File name is missing.';
    }

    if (sizeBytes > maxFileSizeBytes) {
      return 'File size exceeds maximum permitted limit of 5 MiB (5,242,880 bytes)';
    }

    final normalizedMime = mimeType.trim().toLowerCase();
    if (normalizedMime != 'application/pdf' &&
        normalizedMime != 'image/jpeg' &&
        normalizedMime != 'image/png') {
      return 'Unsupported MIME type: $mimeType';
    }

    return null;
  }

  String? resolveMimeType(String fileName) {
    final lower = fileName.toLowerCase().trim();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    return null;
  }

  void _setStatus(
    MedicalRecordsStatus status, {
    required String? errorMessage,
  }) {
    _status = status;
    _errorMessage = errorMessage;
    _safeNotifyListeners();
  }

  void _setUploading(bool value) {
    _isUploading = value;
    _safeNotifyListeners();
  }

  void _setDownloading(bool value) {
    _isDownloading = value;
    _safeNotifyListeners();
  }

  void _setError(String message) {
    _status = MedicalRecordsStatus.error;
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  void _debugLog(String message, Object error, StackTrace stackTrace) {
    AppLogger.error('MedicalRecordsController.$message', error, stackTrace);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
