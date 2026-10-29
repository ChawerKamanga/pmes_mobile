import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pmes_mobile/core/constants/api_constants.dart';
import 'package:pmes_mobile/core/repositories/field_log_repository.dart';
import 'package:pmes_mobile/core/services/local_database.dart';
import 'package:pmes_mobile/core/services/sync_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'uploads with UUID idempotency and marks a successful record synced',
    () async {
      final fixture = await _createFixture();
      addTearDown(fixture.dispose);
      final log = await fixture.repository.writeFieldLog(
        projectId: 'project-1',
        kpisMet: '2 of 5',
        notes: 'Work is progressing.',
        gpsLatitude: -15.4,
        gpsLongitude: 28.2,
        timestamp: DateTime.utc(2026, 10, 29, 12),
      );
      late final http.Request sentRequest;

      final service = SyncService(
        repository: fixture.repository,
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response('{}', 201);
        }),
      );
      addTearDown(service.dispose);

      final finished = _whenSyncFinishes(service);
      service.updateDependencies(isOnline: true, token: 'test-token');
      await finished;

      expect(sentRequest.url.toString(), ApiConstants.fieldUpdatesSync);
      expect(sentRequest.headers['authorization'], 'Bearer test-token');
      expect(sentRequest.headers['idempotency-key'], log.localId);
      expect(
        jsonDecode(sentRequest.body),
        containsPair('local_id', log.localId),
      );
      expect(await fixture.repository.getPendingFieldLogs(), isEmpty);
      expect(service.completedCount, 1);
      expect(service.failedCount, 0);
    },
  );

  test(
    'retains failed uploads and persists the server error for retry',
    () async {
      final fixture = await _createFixture();
      addTearDown(fixture.dispose);
      final log = await fixture.repository.writeFieldLog(
        projectId: 'project-1',
        kpisMet: '2 of 5',
        notes: 'Work is progressing.',
        timestamp: DateTime.utc(2026, 10, 29, 12),
      );
      final service = SyncService(
        repository: fixture.repository,
        client: MockClient(
          (_) async => http.Response('{"message":"Invalid project."}', 422),
        ),
      );
      addTearDown(service.dispose);

      final finished = _whenSyncFinishes(service);
      service.updateDependencies(isOnline: true, token: 'test-token');
      await finished;

      final pending = await fixture.repository.getPendingFieldLogs();
      expect(pending, hasLength(1));
      expect(pending.single.localId, log.localId);
      expect(pending.single.isSynced, isFalse);
      expect(pending.single.lastSyncError, 'Invalid project.');
      expect(pending.single.lastSyncAttemptAt, isNotNull);
      expect(service.failedCount, 1);
    },
  );
}

Future<void> _whenSyncFinishes(SyncService service) {
  final completer = Completer<void>();
  void listener() {
    if (!service.isSyncing &&
        service.totalCount > 0 &&
        !completer.isCompleted) {
      completer.complete();
    }
  }

  service.addListener(listener);
  return completer.future
      .timeout(const Duration(seconds: 5))
      .whenComplete(() => service.removeListener(listener));
}

Future<_SyncFixture> _createFixture() async {
  final directory = await Directory.systemTemp.createTemp('pmes-sync-test-');
  final database = LocalDatabase(
    factory: databaseFactoryFfi,
    databasePath: '${directory.path}/sync-test.db',
  );
  return _SyncFixture(
    directory: directory,
    database: database,
    repository: FieldLogRepository(database: database),
  );
}

class _SyncFixture {
  const _SyncFixture({
    required this.directory,
    required this.database,
    required this.repository,
  });

  final Directory directory;
  final LocalDatabase database;
  final FieldLogRepository repository;

  Future<void> dispose() async {
    await database.close();
    await directory.delete(recursive: true);
  }
}
