class LocalProject {
  const LocalProject({
    required this.id,
    required this.title,
    this.projectCode,
    this.contractRef,
    this.section,
    this.activity,
    this.status,
    this.publicationStatus,
    this.completionStatus,
    this.milestoneCompletion,
    this.approvedBudget,
    this.kpisMet,
    this.lastSynced,
    this.latitude,
    this.longitude,
    this.locationName,
    this.locationAccuracy,
  });

  final String id;
  final String title;
  final String? projectCode;
  final String? contractRef;
  final String? section;
  final String? activity;
  final String? status;
  final String? publicationStatus;
  final String? completionStatus;
  final double? milestoneCompletion;
  final String? approvedBudget;
  final String? kpisMet;
  final String? lastSynced;
  final String? latitude;
  final String? longitude;
  final String? locationName;
  final double? locationAccuracy;

  factory LocalProject.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final statusMap = status is Map ? status : const <String, dynamic>{};
    final stats = json['stats'];
    final statsMap = stats is Map ? stats : const <String, dynamic>{};
    final location = json['location'];
    final locationMap = location is Map ? location : const <String, dynamic>{};

    return LocalProject(
      id: _requiredString(json['id'], 'id'),
      title: _string(json['title']) ?? '',
      projectCode: _string(json['project_code']),
      contractRef: _string(json['contract_ref']),
      section: _string(json['section']),
      activity: _string(json['activity']),
      status: status is Map ? _string(statusMap['progress']) : _string(status),
      publicationStatus:
          _string(json['publication_status']) ??
          _string(statusMap['publication']),
      completionStatus: _string(json['completion_status']),
      milestoneCompletion: _number(json['milestone_completion']),
      approvedBudget:
          _string(json['approved_budget']) ??
          _string(statsMap['approved_budget']),
      kpisMet: _string(json['kpis_met']) ?? _string(statsMap['kpis_met']),
      lastSynced:
          _string(json['last_synced']) ?? _string(statsMap['last_synced']),
      latitude: _string(json['latitude']) ?? _string(locationMap['latitude']),
      longitude:
          _string(json['longitude']) ?? _string(locationMap['longitude']),
      locationName:
          _string(json['location_name']) ?? _string(locationMap['name']),
      locationAccuracy:
          _number(json['location_accuracy']) ??
          _number(locationMap['accuracy']),
    );
  }

  factory LocalProject.fromMap(Map<String, Object?> map) {
    return LocalProject(
      id: map['id']! as String,
      title: map['title']! as String,
      projectCode: map['project_code'] as String?,
      contractRef: map['contract_ref'] as String?,
      section: map['section'] as String?,
      activity: map['activity'] as String?,
      status: map['status'] as String?,
      publicationStatus: map['publication_status'] as String?,
      completionStatus: map['completion_status'] as String?,
      milestoneCompletion: (map['milestone_completion'] as num?)?.toDouble(),
      approvedBudget: map['approved_budget'] as String?,
      kpisMet: map['kpis_met'] as String?,
      lastSynced: map['last_synced'] as String?,
      latitude: map['latitude'] as String?,
      longitude: map['longitude'] as String?,
      locationName: map['location_name'] as String?,
      locationAccuracy: (map['location_accuracy'] as num?)?.toDouble(),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'project_code': projectCode,
    'contract_ref': contractRef,
    'title': title,
    'section': section,
    'activity': activity,
    'status': status,
    'publication_status': publicationStatus,
    'completion_status': completionStatus,
    'milestone_completion': milestoneCompletion,
    'approved_budget': approvedBudget,
    'kpis_met': kpisMet,
    'last_synced': lastSynced,
    'latitude': latitude,
    'longitude': longitude,
    'location_name': locationName,
    'location_accuracy': locationAccuracy,
  };
}

String? _string(Object? value) => value?.toString();

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return value == null ? null : double.tryParse(value.toString());
}

String _requiredString(Object? value, String field) {
  final result = _string(value);
  if (result == null || result.isEmpty) {
    throw FormatException('Project $field is required.');
  }
  return result;
}
