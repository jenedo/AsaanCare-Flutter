// Public named dependency parameters intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import 'dart:collection';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';

import '../../domain/entities/prescription_record.dart';
import '../../domain/usecases/delete_prescription.dart';
import '../../domain/usecases/get_prescriptions.dart';
import '../../domain/usecases/upload_prescription.dart';

enum PrescriptionControllerStatus { initial, loading, loaded, empty, error }

class PrescriptionController extends ChangeNotifier {
  PrescriptionController({
    required GetPrescriptions getPrescriptions,
    required UploadPrescription uploadPrescription,
    required DeletePrescription deletePrescription,
  }) : _getPrescriptions = getPrescriptions,
       _uploadPrescription = uploadPrescription,
       _deletePrescription = deletePrescription;

  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  final GetPrescriptions _getPrescriptions;
  final UploadPrescription _uploadPrescription;
  final DeletePrescription _deletePrescription;

  UnmodifiableListView<PrescriptionRecord> _records =
      UnmodifiableListView<PrescriptionRecord>(const []);

  PrescriptionControllerStatus _status = PrescriptionControllerStatus.initial;
  bool _isUploading = false;
  bool _isDeleting = false;
  bool _isDownloading = false;
  String? _errorMessage;
  bool _isDisposed = false;
  int _deleteOperationId = 0;

  UnmodifiableListView<PrescriptionRecord> get records => _records;
  PrescriptionControllerStatus get status => _status;
  bool get isUploading => _isUploading;
  bool get isDeleting => _isDeleting;
  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == PrescriptionControllerStatus.loading;
  bool get isLoaded => _status == PrescriptionControllerStatus.loaded;
  bool get isEmpty => _status == PrescriptionControllerStatus.empty;
  bool get hasError => _status == PrescriptionControllerStatus.error;

  void reset() {
    _deleteOperationId += 1;
    _records = UnmodifiableListView<PrescriptionRecord>(const []);
    _status = PrescriptionControllerStatus.initial;
    _isUploading = false;
    _isDeleting = false;
    _isDownloading = false;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadPrescriptions({required String patientId}) async {
    final trimmedPatientId = patientId.trim();

    if (trimmedPatientId.isEmpty) {
      _setError('Patient information is missing.');
      return;
    }

    _setStatus(PrescriptionControllerStatus.loading, errorMessage: null);

    try {
      final result = await _getPrescriptions(patientId: trimmedPatientId);

      if (_isDisposed) return;

      _records = UnmodifiableListView<PrescriptionRecord>(result);

      _setStatus(
        result.isEmpty
            ? PrescriptionControllerStatus.empty
            : PrescriptionControllerStatus.loaded,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      _debugLog('loadPrescriptions failed', error, stackTrace);

      if (_isDisposed) return;

      _setStatus(
        PrescriptionControllerStatus.error,
        errorMessage: 'Failed to load health records. Please try again.',
      );
    }
  }

  Future<bool> pickAndUploadFile({required String patientId}) async {
    if (_isUploading) return false;

    final trimmedPatientId = patientId.trim();

    if (trimmedPatientId.isEmpty) {
      _setError('Patient information is missing.');
      return false;
    }

    _setUploading(true);
    _clearError();

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = result.files.single;
      final fileName = file.name.trim();
      final Uint8List? bytes = file.bytes;

      final validationError = _validatePickedFile(
        fileName: fileName,
        bytes: bytes,
      );

      if (validationError != null) {
        _setError(validationError);
        return false;
      }

      final contentType = _resolveContentType(fileName);

      if (contentType == null) {
        _setError('Only PDF, JPG, JPEG, and PNG files are allowed.');
        return false;
      }

      final uploadedRecord = await _uploadPrescription(
        patientId: trimmedPatientId,
        fileName: fileName,
        fileBytes: bytes!,
        contentType: contentType,
      );

      if (_isDisposed) return false;

      _records = UnmodifiableListView<PrescriptionRecord>([
        uploadedRecord,
        ..._records,
      ]);

      _setStatus(PrescriptionControllerStatus.loaded, errorMessage: null);
      return true;
    } catch (error, stackTrace) {
      _debugLog('pickAndUploadFile failed', error, stackTrace);

      if (_isDisposed) return false;

      _setError('Upload failed. Please try again.');
      return false;
    } finally {
      _setUploading(false);
    }
  }

  Future<bool> downloadRecord(PrescriptionRecord record) async {
    if (_isDownloading) return false;

    final bytes = record.fileBytes;

    if (bytes == null || bytes.isEmpty) {
      _setError(
        'This record is not cached locally. A backend signed-download API is required.',
      );
      return false;
    }

    _setDownloading(true);
    _clearError();

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save health record',
        fileName: record.fileName,
        type: FileType.custom,
        allowedExtensions: [_extensionOf(record.fileName)],
        bytes: bytes,
      );

      if (_isDisposed) return false;

      if (kIsWeb) {
        return true;
      }

      return result != null;
    } catch (error, stackTrace) {
      _debugLog('downloadRecord failed', error, stackTrace);

      if (_isDisposed) return false;

      _setError('Download failed. Please try again.');
      return false;
    } finally {
      _setDownloading(false);
    }
  }

  Future<bool> deleteRecord({
    required String patientId,
    required String prescriptionId,
  }) async {
    if (_isDeleting) return false;

    final trimmedPatientId = patientId.trim();
    final trimmedPrescriptionId = prescriptionId.trim();

    if (trimmedPatientId.isEmpty || trimmedPrescriptionId.isEmpty) {
      _setError('Record information is missing.');
      return false;
    }

    final deleteOperationId = ++_deleteOperationId;
    final previousRecords = _records;
    final previousStatus = _status;
    final optimisticRecords = previousRecords
        .where((record) => record.id != trimmedPrescriptionId)
        .toList(growable: false);

    _records = UnmodifiableListView<PrescriptionRecord>(optimisticRecords);
    _status = optimisticRecords.isEmpty
        ? PrescriptionControllerStatus.empty
        : PrescriptionControllerStatus.loaded;
    _isDeleting = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      await _deletePrescription(
        patientId: trimmedPatientId,
        prescriptionId: trimmedPrescriptionId,
      );

      if (_isDisposed || deleteOperationId != _deleteOperationId) return false;

      _isDeleting = false;
      _safeNotifyListeners();
      return true;
    } catch (error, stackTrace) {
      _debugLog('deleteRecord failed', error, stackTrace);

      if (_isDisposed || deleteOperationId != _deleteOperationId) return false;

      _records = previousRecords;
      _status = previousStatus;
      _isDeleting = false;
      _errorMessage = 'Delete failed. The record was restored.';

      _safeNotifyListeners();
      return false;
    }
  }

  String? _validatePickedFile({
    required String fileName,
    required Uint8List? bytes,
  }) {
    if (fileName.isEmpty) {
      return 'File name is missing.';
    }

    if (bytes == null || bytes.isEmpty) {
      return 'Could not read the selected file.';
    }

    if (bytes.lengthInBytes > maxFileSizeBytes) {
      return 'File size must be 5 MB or less.';
    }

    if (_resolveContentType(fileName) == null) {
      return 'Only PDF, JPG, JPEG, and PNG files are allowed.';
    }

    return null;
  }

  String? _resolveContentType(String fileName) {
    final lower = fileName.toLowerCase().trim();

    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.jpg')) return 'image/jpeg';
    if (lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';

    return null;
  }

  String _extensionOf(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return 'pdf';
    return parts.last.toLowerCase();
  }

  void _setStatus(
    PrescriptionControllerStatus status, {
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
    _status = PrescriptionControllerStatus.error;
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
    AppLogger.error('PrescriptionController.$message', error, stackTrace);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
