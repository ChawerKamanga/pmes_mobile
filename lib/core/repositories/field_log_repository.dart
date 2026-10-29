import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/field_progress_log.dart';
import '../models/local_project.dart';
import '../services/local_database.dart';

class FieldLogRepository {
  FieldLogRepository({LocalDatabase? database, Uuid? uuid})
    : _database = database ?? LocalDatabase.instance,
      _uuid = uuid ?? const Uuid();

  final LocalDatabase _database;
  final Uuid _uuid;

  Future<void> saveProject(LocalProject project) {
    return _run('save project', (database) async {
      await database.insert(
        'projects',
        project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> saveProjects(Iterable<LocalProject> projects) {
    return _run('save projects', (database) async {
      await database.transaction((transaction) async {
        final batch = transaction.batch();
        for (final project in projects) {
          batch.insert(
            'projects',
            project.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });
    });
  }

  Future<FieldProgressLog> writeFieldLog({
    required String projectId,
    required String kpisMet,
    required String notes,
    double? gpsLatitude,
    double? gpsLongitude,
    DateTime? timestamp,
  }) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError.value(projectId, 'projectId', 'Must not be empty.');
    }
    if (gpsLatitude != null && (gpsLatitude < -90 || gpsLatitude > 90)) {
      throw ArgumentError.value(
        gpsLatitude,
        'gpsLatitude',
        'Must be between -90 and 90.',
      );
    }
    if (gpsLongitude != null && (gpsLongitude < -180 || gpsLongitude > 180)) {
      throw ArgumentError.value(
        gpsLongitude,
        'gpsLongitude',
        'Must be between -180 and 180.',
      );
    }

    final log = FieldProgressLog(
      localId: _uuid.v4(),
      projectId: projectId,
      kpisMet: kpisMet,
      notes: notes,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
    );

    return _run('write field log', (database) async {
      final id = await database.insert('progress_logs', log.toMap());
      return log.copyWith(id: id);
    });
  }

  Future<List<FieldProgressLog>> getPendingFieldLogs() {
    return _run('fetch pending field logs', (database) async {
      final rows = await database.rawQuery('''
        SELECT progress_logs.*, projects.title AS project_title
        FROM progress_logs
        LEFT JOIN projects ON projects.id = progress_logs.project_id
        WHERE progress_logs.is_synced = 0
        ORDER BY progress_logs."timestamp" ASC, progress_logs.id ASC
      ''');
      return rows.map(FieldProgressLog.fromMap).toList(growable: false);
    });
  }

  Future<void> markFieldLogSynced(String localId) {
    if (localId.trim().isEmpty) {
      throw ArgumentError.value(localId, 'localId', 'Must not be empty.');
    }
    return _run('mark field log synced', (database) async {
      final updated = await database.update(
        'progress_logs',
        {
          'is_synced': 1,
          'last_sync_attempt_at': DateTime.now().toUtc().toIso8601String(),
          'last_sync_error': null,
        },
        where: 'local_id = ? AND is_synced = 0',
        whereArgs: [localId],
      );
      if (updated == 0) {
        final existing = await database.query(
          'progress_logs',
          columns: ['is_synced'],
          where: 'local_id = ?',
          whereArgs: [localId],
          limit: 1,
        );
        if (existing.isEmpty) {
          throw StateError('No field log exists with local ID $localId.');
        }
      }
    });
  }

  Future<void> recordFieldLogSyncAttempt(
    String localId, {
    DateTime? attemptedAt,
  }) {
    if (localId.trim().isEmpty) {
      throw ArgumentError.value(localId, 'localId', 'Must not be empty.');
    }
    return _run('record field log sync attempt', (database) async {
      final updated = await database.update(
        'progress_logs',
        {
          'last_sync_attempt_at': (attemptedAt ?? DateTime.now())
              .toUtc()
              .toIso8601String(),
          'last_sync_error': null,
        },
        where: 'local_id = ? AND is_synced = 0',
        whereArgs: [localId],
      );
      if (updated == 0) {
        final existing = await database.query(
          'progress_logs',
          columns: ['is_synced'],
          where: 'local_id = ?',
          whereArgs: [localId],
          limit: 1,
        );
        if (existing.isEmpty) {
          throw StateError('No field log exists with local ID $localId.');
        }
      }
    });
  }

  Future<void> recordFieldLogSyncFailure(
    String localId,
    String message, {
    DateTime? attemptedAt,
  }) {
    if (localId.trim().isEmpty) {
      throw ArgumentError.value(localId, 'localId', 'Must not be empty.');
    }
    final error = message.trim();
    if (error.isEmpty) {
      throw ArgumentError.value(message, 'message', 'Must not be empty.');
    }
    return _run('record field log sync failure', (database) async {
      final updated = await database.update(
        'progress_logs',
        {
          'last_sync_attempt_at': (attemptedAt ?? DateTime.now())
              .toUtc()
              .toIso8601String(),
          'last_sync_error': error.length > 1000
              ? error.substring(0, 1000)
              : error,
        },
        where: 'local_id = ? AND is_synced = 0',
        whereArgs: [localId],
      );
      if (updated == 0) {
        final existing = await database.query(
          'progress_logs',
          columns: ['is_synced'],
          where: 'local_id = ?',
          whereArgs: [localId],
          limit: 1,
        );
        if (existing.isEmpty) {
          throw StateError('No field log exists with local ID $localId.');
        }
      }
    });
  }

  Future<T> _run<T>(
    String operation,
    Future<T> Function(Database database) action,
  ) async {
    try {
      return await action(await _database.database);
    } on DatabaseException catch (error) {
      throw LocalDatabaseException('Unable to $operation.', cause: error);
    }
  }
}
