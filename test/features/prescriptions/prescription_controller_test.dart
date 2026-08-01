import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asaancare/core/logging/app_logger.dart';
import 'package:asaancare/features/prescriptions/domain/entities/prescription_record.dart';
import 'package:asaancare/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:asaancare/features/prescriptions/domain/usecases/delete_prescription.dart';
import 'package:asaancare/features/prescriptions/domain/usecases/get_prescriptions.dart';
import 'package:asaancare/features/prescriptions/domain/usecases/upload_prescription.dart';
import 'package:asaancare/features/prescriptions/presentation/controllers/prescription_controller.dart';
import 'package:asaancare/features/prescriptions/presentation/screens/medical_records_screen.dart';

void main() {
  setUp(() {
    AppLogger.setErrorReporter((_) {});
  });

  tearDown(AppLogger.resetErrorReporter);

  group('PrescriptionController optimistic deletion', () {
    late _DeferredDeletePrescriptionRepository repository;
    late PrescriptionController controller;

    setUp(() async {
      repository = _DeferredDeletePrescriptionRepository(
        records: [
          _record(id: 'record-1'),
          _record(id: 'record-2'),
        ],
      );
      controller = PrescriptionController(
        getPrescriptions: GetPrescriptions(repository),
        uploadPrescription: UploadPrescription(repository),
        deletePrescription: DeletePrescription(repository),
      );
      await controller.loadPrescriptions(patientId: 'patient-1');
    });

    tearDown(() {
      controller.dispose();
    });

    test('removes the record before the server responds', () async {
      final deletion = controller.deleteRecord(
        patientId: 'patient-1',
        prescriptionId: 'record-1',
      );

      expect(repository.deleteCallCount, 1);
      expect(controller.isDeleting, isTrue);
      expect(controller.records.map((record) => record.id), ['record-2']);

      repository.completeDelete();

      expect(await deletion, isTrue);
      expect(controller.records.map((record) => record.id), ['record-2']);
      expect(controller.isDeleting, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test(
      'restores the record visibly when the server rejects deletion',
      () async {
        final visibleRecordSnapshots = <List<String>>[];
        controller.addListener(() {
          visibleRecordSnapshots.add(
            controller.records.map((record) => record.id).toList(),
          );
        });

        final deletion = controller.deleteRecord(
          patientId: 'patient-1',
          prescriptionId: 'record-1',
        );

        expect(controller.records.map((record) => record.id), ['record-2']);

        repository.failDelete(StateError('server rejected deletion'));

        expect(await deletion, isFalse);
        expect(controller.records.map((record) => record.id), [
          'record-1',
          'record-2',
        ]);
        expect(controller.status, PrescriptionControllerStatus.loaded);
        expect(controller.isDeleting, isFalse);
        expect(
          controller.errorMessage,
          'Delete failed. The record was restored.',
        );
        expect(
          visibleRecordSnapshots,
          anyElement(orderedEquals(<String>['record-2'])),
        );
        expect(
          visibleRecordSnapshots,
          anyElement(orderedEquals(<String>['record-1', 'record-2'])),
        );
      },
    );

    test(
      'does not restore stale records after user-scoped state resets',
      () async {
        final deletion = controller.deleteRecord(
          patientId: 'patient-1',
          prescriptionId: 'record-1',
        );

        controller.reset();
        repository.failDelete(StateError('late server failure'));

        expect(await deletion, isFalse);
        expect(controller.records, isEmpty);
        expect(controller.status, PrescriptionControllerStatus.initial);
        expect(controller.isDeleting, isFalse);
        expect(controller.errorMessage, isNull);
      },
    );
  });

  testWidgets('failed deletion restores the row and explains the rollback', (
    tester,
  ) async {
    final repository = _DeferredDeletePrescriptionRepository(
      records: [
        _record(id: 'record-1'),
        _record(id: 'record-2'),
      ],
    );
    final controller = PrescriptionController(
      getPrescriptions: GetPrescriptions(repository),
      uploadPrescription: UploadPrescription(repository),
      deletePrescription: DeletePrescription(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MedicalRecordsScreen(
          controller: controller,
          patientId: 'patient-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('record-1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('record-1'), findsNothing);
    expect(find.text('record-2'), findsOneWidget);

    repository.failDelete(StateError('server rejected deletion'));
    await tester.pumpAndSettle();

    expect(find.text('record-1'), findsOneWidget);
    expect(find.text('record-2'), findsOneWidget);
    expect(
      find.text('Delete failed. The record was restored.'),
      findsOneWidget,
    );
  });
}

PrescriptionRecord _record({required String id}) {
  return PrescriptionRecord(
    id: id,
    patientId: 'patient-1',
    fileName: '$id.pdf',
    uploadedAt: DateTime.utc(2026, 1, 1),
    source: PrescriptionSource.patientUploaded,
    status: PrescriptionStatus.reviewed,
    recordType: HealthRecordType.prescription,
    title: id,
    summary: 'Test record',
    issuer: 'Test clinic',
  );
}

class _DeferredDeletePrescriptionRepository implements PrescriptionRepository {
  _DeferredDeletePrescriptionRepository({required this.records});

  final List<PrescriptionRecord> records;
  final Completer<void> _deleteCompleter = Completer<void>();
  int deleteCallCount = 0;

  void completeDelete() => _deleteCompleter.complete();

  void failDelete(Object error) {
    _deleteCompleter.completeError(error, StackTrace.current);
  }

  @override
  Future<void> deletePrescription({
    required String patientId,
    required String prescriptionId,
  }) {
    deleteCallCount += 1;
    return _deleteCompleter.future;
  }

  @override
  Future<List<PrescriptionRecord>> getPrescriptions({
    required String patientId,
  }) async {
    return records;
  }

  @override
  Future<PrescriptionRecord> uploadPrescription({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) {
    throw UnimplementedError();
  }
}
