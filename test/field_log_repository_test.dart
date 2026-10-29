import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pmes_mobile/core/models/local_project.dart';
import 'package:pmes_mobile/core/repositories/field_log_repository.dart';
import 'package:pmes_mobile/core/services/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'field logs are persisted as pending and can be marked synced',
    () async {
      final directory = await Directory.systemTemp.createTemp('pmes-db-test-');
      final localDatabase = LocalDatabase(
        factory: databaseFactoryFfi,
        databasePath: '${directory.path}/test.db',
      );
      addTearDown(() async {
        await localDatabase.close();
        await directory.delete(recursive: true);
      });

      final repository = FieldLogRepository(database: localDatabase);
      await repository.saveProject(
        const LocalProject(id: 'project-1', title: 'Mupila Health Centre'),
      );
      final createdAt = DateTime.utc(2026, 10, 29, 12);

      final log = await repository.writeFieldLog(
        projectId: 'project-1',
        kpisMet: '3 of 5',
        notes: 'Foundation work is in progress.',
        gpsLatitude: -15.4167,
        gpsLongitude: 28.2833,
        timestamp: createdAt,
      );

      expect(log.localId, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(log.isSynced, isFalse);
      expect(log.timestamp, createdAt);

      final pending = await repository.getPendingFieldLogs();
      expect(pending, hasLength(1));
      expect(pending.single.localId, log.localId);
      expect(pending.single.projectTitle, 'Mupila Health Centre');
      expect(pending.single.gpsLatitude, -15.4167);

      await repository.markFieldLogSynced(log.localId);
      expect(await repository.getPendingFieldLogs(), isEmpty);
    },
  );

  test('project mapper reads the dashboard project shape', () {
    final project = LocalProject.fromJson({
      'id': 42,
      'contract_ref': 'CTR-42',
      'title': 'Road rehabilitation',
      'status': {'publication': 'published', 'progress': 'in_progress'},
      'milestone_completion': 0.4,
      'stats': {'kpis_met': '2 of 5'},
      'location': {'latitude': '-15.4', 'longitude': '28.2', 'name': 'Lusaka'},
    });

    expect(project.id, '42');
    expect(project.contractRef, 'CTR-42');
    expect(project.status, 'in_progress');
    expect(project.publicationStatus, 'published');
    expect(project.milestoneCompletion, 0.4);
    expect(project.kpisMet, '2 of 5');
    expect(project.locationName, 'Lusaka');
  });
}
