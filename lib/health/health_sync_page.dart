import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthSyncPage extends StatefulWidget {
  const HealthSyncPage({super.key});

  @override
  State<HealthSyncPage> createState() => _HealthSyncPageState();
}

enum SyncState {
  idle,
  checkingHealthConnect,
  needsHealthConnect,
  requestingPermissions,
  authorized,
  notAuthorized,
  fetching,
  synced,
  noData,
  error,
}

// Platform-specific health data types to read/write
final List<HealthDataType> _dataTypesAndroid = <HealthDataType>[
  HealthDataType.STEPS,
  HealthDataType.HEART_RATE,
  HealthDataType.WEIGHT,
  HealthDataType.HEIGHT,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.SLEEP_AWAKE,
  HealthDataType.BODY_TEMPERATURE,
  HealthDataType.BLOOD_GLUCOSE,
  HealthDataType.WORKOUT,
];

final List<HealthDataType> _dataTypesIOS = <HealthDataType>[
  HealthDataType.STEPS,
  HealthDataType.HEART_RATE,
  HealthDataType.WEIGHT,
  HealthDataType.HEIGHT,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.SLEEP_AWAKE,
  HealthDataType.BODY_TEMPERATURE,
  HealthDataType.BLOOD_GLUCOSE,
  HealthDataType.WORKOUT,
];

class _HealthSyncPageState extends State<HealthSyncPage> {
  final Health _health = Health();

  SyncState _syncState = SyncState.idle;
  String _message = '';
  int _fetchedCount = 0;
  HealthConnectSdkStatus? _healthConnectStatus;
  List<HealthDataPoint> _points = <HealthDataPoint>[];

  List<HealthDataType> get _types => (Platform.isAndroid)
      ? _dataTypesAndroid
      : (Platform.isIOS)
          ? _dataTypesIOS
          : [];

  List<HealthDataAccess> get _permissions => _types
      .map((type) =>
          [
            HealthDataType.GENDER,
            HealthDataType.BLOOD_TYPE,
            HealthDataType.BIRTH_DATE,
            HealthDataType.APPLE_MOVE_TIME,
            HealthDataType.APPLE_STAND_HOUR,
            HealthDataType.APPLE_STAND_TIME,
            HealthDataType.WALKING_HEART_RATE,
            HealthDataType.ELECTROCARDIOGRAM,
            HealthDataType.HIGH_HEART_RATE_EVENT,
            HealthDataType.LOW_HEART_RATE_EVENT,
            HealthDataType.IRREGULAR_HEART_RATE_EVENT,
            HealthDataType.EXERCISE_TIME,
          ].contains(type)
              ? HealthDataAccess.READ
              : HealthDataAccess.READ_WRITE)
      .toList();

  @override
  void initState() {
    super.initState();
    // Configure and pre-check Health Connect status
    _health.configure();
    if (Platform.isAndroid) {
      _checkHealthConnectStatus();
    }
  }

  Future<void> _checkHealthConnectStatus() async {
    setState(() {
      _syncState = SyncState.checkingHealthConnect;
      _message = 'Checking Health Connect status...';
    });

    try {
      final status = await _health.getHealthConnectSdkStatus();
      setState(() {
        _healthConnectStatus = status;
        if (status == HealthConnectSdkStatus.sdkAvailable) {
          _message = 'Health Connect is available.';
          _syncState = SyncState.idle;
        } else {
          _message = 'Health Connect not available (${status?.name}).';
          _syncState = SyncState.needsHealthConnect;
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to check Health Connect status: $e';
        _syncState = SyncState.error;
      });
    }
  }

  Future<void> _installHealthConnect() async {
    try {
      await _health.installHealthConnect();
      await _checkHealthConnectStatus();
    } catch (e) {
      setState(() {
        _message = 'Failed to open Health Connect install: $e';
        _syncState = SyncState.error;
      });
    }
  }

  Future<void> _authorize() async {
    setState(() {
      _syncState = SyncState.requestingPermissions;
      _message = 'Requesting permissions...';
    });

    try {
      // Extra runtime permissions when needed
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
        await Permission.location.request();
      }

      bool? hasPermissions =
          await _health.hasPermissions(_types, permissions: _permissions);

      // As in example: ensure we request WRITE too
      hasPermissions = false;

      bool authorized = false;
      if (!hasPermissions) {
        authorized = await _health.requestAuthorization(_types,
            permissions: _permissions);
        // Optional extended authorizations on Android (history/background)
        try {
          await _health.requestHealthDataHistoryAuthorization();
          await _health.requestHealthDataInBackgroundAuthorization();
        } catch (_) {}
      } else {
        authorized = true;
      }

      setState(() {
        _syncState = authorized ? SyncState.authorized : SyncState.notAuthorized;
        _message = authorized ? 'Permissions granted.' : 'Authorization denied.';
      });
    } catch (e) {
      setState(() {
        _syncState = SyncState.error;
        _message = 'Error during authorization: $e';
      });
    }
  }

  Future<void> _fetchLatest() async {
    setState(() {
      _syncState = SyncState.fetching;
      _message = 'Fetching last 24h of health data...';
      _fetchedCount = 0;
      _points = <HealthDataPoint>[];
    });

    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 24));

      final points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: now,
      );

      // Remove duplicates
      final deduped = Health().removeDuplicates(points);

      setState(() {
        _fetchedCount = deduped.length;
        _points = deduped;
        if (_fetchedCount > 0) {
          _syncState = SyncState.synced;
          _message = 'Synced! Loaded $_fetchedCount data points.';
        } else {
          _syncState = SyncState.noData;
          _message = 'No data found in the last 24h.';
        }
      });
    } catch (e) {
      setState(() {
        _syncState = SyncState.error;
        _message = 'Failed to fetch data: $e';
      });
    }
  }

  Widget _buildStatusChip() {
    Color bg;
    String text;

    switch (_syncState) {
      case SyncState.synced:
        bg = CupertinoColors.systemGreen;
        text = 'Synced';
        break;
      case SyncState.fetching:
      case SyncState.requestingPermissions:
      case SyncState.checkingHealthConnect:
        bg = CupertinoColors.systemOrange;
        text = 'Loading...';
        break;
      case SyncState.notAuthorized:
      case SyncState.needsHealthConnect:
        bg = CupertinoColors.systemRed;
        text = 'Action required';
        break;
      case SyncState.noData:
        bg = CupertinoColors.systemGrey;
        text = 'No data';
        break;
      case SyncState.error:
        bg = CupertinoColors.systemRed;
        text = 'Error';
        break;
      case SyncState.idle:
      case SyncState.authorized:
      default:
        bg = CupertinoColors.systemBlue;
        text = 'Idle';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Health Sync'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health data status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: const TextStyle(color: CupertinoColors.black),
            ),
            const SizedBox(height: 16),
            if (Platform.isAndroid) ...[
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: _checkHealthConnectStatus,
                      child: const Text('Check Health Connect'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoButton(
                      onPressed: (_healthConnectStatus ==
                              HealthConnectSdkStatus.sdkAvailable)
                          ? null
                          : _installHealthConnect,
                      child: const Text('Install Health Connect'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: _authorize,
                    child: const Text('Authorize'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoButton(
                    onPressed: (_syncState == SyncState.authorized ||
                            _syncState == SyncState.synced ||
                            _syncState == SyncState.noData)
                        ? _fetchLatest
                        : _fetchLatest,
                    child: const Text('Fetch 24h Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('Platform: ${Platform.isIOS ? 'iOS (HealthKit)' : Platform.isAndroid ? 'Android (Health Connect)' : 'Unsupported'}'),
                    Text('Health Connect: ${_healthConnectStatus?.name ?? 'N/A'}'),
                    Text('Fetched data points: $_fetchedCount'),
                    const SizedBox(height: 12),
                    const Text(
                      'Data (latest first)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _points.isEmpty
                          ? const Center(
                              child: Text('No data'),
                            )
                          : ListView.separated(
                              itemCount: _points.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 1),
                              itemBuilder: (_, int index) {
                                final p = _points[index];
                                final String type = p.typeString;
                                final String unit = p.unitString;
                                final String value = p.value.toString();
                                final String timeRange = '${p.dateFrom} - ${p.dateTo}';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('$value $unit', style: const TextStyle(color: CupertinoColors.label)),
                                    const SizedBox(height: 2),
                                    Text(timeRange, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 12)),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
