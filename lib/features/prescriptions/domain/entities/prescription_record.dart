import 'dart:typed_data';

enum PrescriptionSource { patientUploaded, doctorIssued }

enum PrescriptionStatus { pending, reviewed, rejected }

enum HealthRecordType { prescription, labReport, imaging }

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
    required this.recordType,
    required this.title,
    required this.summary,
    required this.issuer,
  });

  final String id;
  final String patientId;
  final String fileName;

  /// Temporary local bytes or demo downloadable bytes.
  /// Production should fetch short-lived signed bytes from authenticated storage.
  final Uint8List? fileBytes;

  /// Backend/private storage URL.
  /// Production should use a short-lived signed/private URL, never a public URL.
  final String? fileUrl;

  final DateTime uploadedAt;
  final PrescriptionSource source;
  final PrescriptionStatus status;
  final HealthRecordType recordType;
  final String title;
  final String summary;
  final String issuer;

  bool get hasLocalFile => fileBytes != null && fileBytes!.isNotEmpty;

  bool get isUploaded =>
      hasLocalFile || (fileUrl != null && fileUrl!.trim().isNotEmpty);

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
    HealthRecordType? recordType,
    String? title,
    String? summary,
    String? issuer,
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
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      issuer: issuer ?? this.issuer,
    );
  }
}

extension PrescriptionSourceX on PrescriptionSource {
  String get label {
    return switch (this) {
      PrescriptionSource.patientUploaded => 'Patient Uploaded',
      PrescriptionSource.doctorIssued => 'Doctor Issued',
    };
  }
}

extension PrescriptionStatusX on PrescriptionStatus {
  String get label {
    return switch (this) {
      PrescriptionStatus.pending => 'Pending',
      PrescriptionStatus.reviewed => 'Reviewed',
      PrescriptionStatus.rejected => 'Rejected',
    };
  }
}

extension HealthRecordTypeX on HealthRecordType {
  String get label {
    return switch (this) {
      HealthRecordType.prescription => 'Prescription',
      HealthRecordType.labReport => 'Lab Report',
      HealthRecordType.imaging => 'Imaging',
    };
  }
}
