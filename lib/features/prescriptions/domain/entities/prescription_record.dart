import 'dart:typed_data';

enum PrescriptionSource { patientUploaded, doctorIssued }

enum PrescriptionStatus { pending, reviewed, rejected }

class PrescriptionRecord {
  const PrescriptionRecord({
    required this.id,
    required this.patientId,
    required this.fileName,
    this.fileBytes,
    this.fileUrl,
    required this.uploadedAt,
    required this.source,
    required this.status,
  });

  final String id;
  final String patientId;
  final String fileName;

  /// Temporary local bytes before upload.
  /// Do not keep this permanently after backend upload.
  final Uint8List? fileBytes;

  /// Backend/private storage URL.
  /// In real production this should be a signed/private URL, not public.
  final String? fileUrl;

  final DateTime uploadedAt;
  final PrescriptionSource source;
  final PrescriptionStatus status;

  bool get hasLocalFile => fileBytes != null && fileBytes!.isNotEmpty;

  bool get isUploaded => fileUrl != null && fileUrl!.trim().isNotEmpty;

  bool get isPending => status == PrescriptionStatus.pending;

  bool get isReviewed => status == PrescriptionStatus.reviewed;

  bool get isRejected => status == PrescriptionStatus.rejected;

  PrescriptionRecord copyWith({
    String? id,
    String? patientId,
    String? fileName,
    Uint8List? fileBytes,
    String? fileUrl,
    DateTime? uploadedAt,
    PrescriptionSource? source,
    PrescriptionStatus? status,
  }) {
    return PrescriptionRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      fileName: fileName ?? this.fileName,
      fileBytes: fileBytes ?? this.fileBytes,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      source: source ?? this.source,
      status: status ?? this.status,
    );
  }
}

extension PrescriptionSourceX on PrescriptionSource {
  String get label {
    switch (this) {
      case PrescriptionSource.patientUploaded:
        return 'Patient Uploaded';
      case PrescriptionSource.doctorIssued:
        return 'Doctor Issued';
    }
  }
}

extension PrescriptionStatusX on PrescriptionStatus {
  String get label {
    switch (this) {
      case PrescriptionStatus.pending:
        return 'Pending';
      case PrescriptionStatus.reviewed:
        return 'Reviewed';
      case PrescriptionStatus.rejected:
        return 'Rejected';
    }
  }
}
