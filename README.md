# pmes_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Offline field data

The mobile app stores projects and field progress logs in a local SQLite
database (`pmes_mobile.db`). `FieldLogRepository.writeFieldLog` writes new logs
with a generated UUID and `is_synced = 0`; `getPendingFieldLogs` returns the
pending queue, including the cached project title and any previous sync error.
`ConnectivityProvider` monitors network transport and internet access, while
`SyncService` uploads pending field updates in batches of up to 100 to
`/api/v1/sync/batch` when online and authenticated. Each item contains the
record UUID, project ID, KPIs met, notes, GPS latitude, GPS longitude, and UTC
timestamp as strings; missing GPS values are sent as empty strings. Records are
marked synced only when the server returns a successful result for their local
UUID. Failed or missing item results remain queued with a persisted error and
retry automatically after the next connection cycle or manually from the Sync
Queue screen.
