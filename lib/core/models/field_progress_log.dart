class FieldProgressLog {
  const FieldProgressLog({
    this.id,
    required this.localId,
    required this.projectId,
    required this.kpisMet,
    required this.notes,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.timestamp,
    this.isSynced = false,
    this.projectTitle,
    this.lastSyncAttemptAt,
    this.lastSyncError,
  });

  final int? id;
  final String localId;
  final String projectId;
  final String kpisMet;
  final String notes;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final DateTime timestamp;
  final bool isSynced;
  final String? projectTitle;
  final DateTime? lastSyncAttemptAt;
  final String? lastSyncError;

  factory FieldProgressLog.fromMap(Map<String, Object?> map) {
    return FieldProgressLog(
      id: map['id'] as int?,
      localId: map['local_id']! as String,
      projectId: map['project_id']! as String,
      kpisMet: map['kpis_met'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      gpsLatitude: (map['gps_lat'] as num?)?.toDouble(),
      gpsLongitude: (map['gps_lng'] as num?)?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']! as String).toUtc(),
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      projectTitle: map['project_title'] as String?,
      lastSyncAttemptAt: map['last_sync_attempt_at'] == null
          ? null
          : DateTime.parse(map['last_sync_attempt_at']! as String).toUtc(),
      lastSyncError: map['last_sync_error'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'local_id': localId,
    'project_id': projectId,
    'kpis_met': kpisMet,
    'notes': notes,
    'gps_lat': gpsLatitude,
    'gps_lng': gpsLongitude,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
    'last_sync_attempt_at': lastSyncAttemptAt?.toUtc().toIso8601String(),
    'last_sync_error': lastSyncError,
  };

  FieldProgressLog copyWith({int? id}) {
    return FieldProgressLog(
      id: id ?? this.id,
      localId: localId,
      projectId: projectId,
      kpisMet: kpisMet,
      notes: notes,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      timestamp: timestamp,
      isSynced: isSynced,
      projectTitle: projectTitle,
      lastSyncAttemptAt: lastSyncAttemptAt,
      lastSyncError: lastSyncError,
    );
  }
}
