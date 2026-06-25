import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class LocationServices extends ChangeNotifier {
  static const String _locationTaskName = 'locationTask';
  static const String _locationTask = 'provideBGLoc';
  static const String _locationTaskTag = 'location';
  static const String _prefsUserIdKey = 'userId';
  static const String _prefsTrackingActiveKey = 'isLocationTrackingActive';
  static const String _prefsSessionIdKey = 'activeWorkSessionId';
  static const String _prefsLastHistoryWriteKey = 'lastLocationHistoryWrite';
  static const Duration foregroundInterval = Duration(seconds: 60);
  static const Duration backgroundInterval = Duration(minutes: 15);
  static const Duration historyInterval = Duration(minutes: 15);
  static const double movementThresholdMeters = 75;

  static final LocationServices _instance = LocationServices._internal();

  factory LocationServices() => _instance;

  LocationServices._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _foregroundTimer;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  Future<bool> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return false;
      }

      PermissionStatus locationPermission = await Permission.location.request();
      if (locationPermission.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      if (!locationPermission.isGranted) {
        return false;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final alwaysStatus = await Permission.locationAlways.status;
        if (!alwaysStatus.isGranted) {
          await Permission.locationAlways.request();
        }
      }

      notifyListeners();
      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return false;
    }
  }

  String dateTime() {
    return DateFormat('hh:mma dd/MM/yyyy').format(DateTime.now());
  }

  Future<bool> startWorkDayTracking(String uid) async {
    try {
      if (uid.isEmpty) {
        return false;
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return false;
      }

      final sessionId = _todaySessionId(uid);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsUserIdKey, uid);
      await prefs.setBool(_prefsTrackingActiveKey, true);
      await prefs.setString(_prefsSessionIdKey, sessionId);

      await _writeSessionState(
        uid: uid,
        sessionId: sessionId,
        isActive: true,
        status: 'active',
      );

      await getLocation(uid, sessionId: sessionId, source: 'start_day');
      await _startForegroundTracking(uid, sessionId);
      await registerBackgroundTracking(uid, sessionId: sessionId);

      _isTracking = true;
      notifyListeners();
      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return false;
    }
  }

  Future<bool> endWorkDayTracking(String uid) async {
    try {
      if (uid.isEmpty) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final sessionId =
          prefs.getString(_prefsSessionIdKey) ?? _todaySessionId(uid);

      await getLocation(uid, sessionId: sessionId, source: 'end_day');
      await _stopLocalTracking();
      await cancelBackgroundTracking();

      await _writeSessionState(
        uid: uid,
        sessionId: sessionId,
        isActive: false,
        status: 'ended',
      );

      await _updateDcrCheckOut(uid);

      await prefs.setBool(_prefsTrackingActiveKey, false);
      await prefs.remove(_prefsSessionIdKey);
      await prefs.remove(_prefsLastHistoryWriteKey);

      _isTracking = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return false;
    }
  }

  Future<void> _updateDcrCheckOut(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final displayName = userDoc.data()?['displayName'] as String?;
      if (displayName == null || displayName.isEmpty) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];

      final reportsSnapshot = await _firestore
          .collection('daily_call_reports')
          .where('submittedBy', isEqualTo: displayName)
          .get();

      for (final doc in reportsSnapshot.docs) {
        final dateStr = doc.data()['date'] as String?;
        if (dateStr != null && dateStr.startsWith(todayStart)) {
          final nowTime = DateFormat('hh:mm a').format(now);
          await doc.reference.update({
            'checkOutTime': nowTime,
          });
        }
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }

  Future<void> resumeTrackingIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_prefsTrackingActiveKey) ?? false;
    final uid = prefs.getString(_prefsUserIdKey);
    final sessionId = prefs.getString(_prefsSessionIdKey);

    if (!isActive || uid == null || uid.isEmpty || sessionId == null) {
      return;
    }

    await _startForegroundTracking(uid, sessionId);
    await registerBackgroundTracking(uid, sessionId: sessionId);
    _isTracking = true;
    notifyListeners();
  }

  Future<bool> getBackgroundLocation(String uid) async {
    try {
      if (uid.isEmpty) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool(_prefsTrackingActiveKey) ?? false;
      if (!isActive) {
        return true;
      }

      final sessionId =
          prefs.getString(_prefsSessionIdKey) ?? _todaySessionId(uid);
      await getLocation(uid, sessionId: sessionId, source: 'background');
      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return false;
    }
  }

  Future<bool> getLocation(
    String uid, {
    String? sessionId,
    String source = 'manual',
    bool forceHistory = false,
  }) async {
    try {
      if (uid.isEmpty) {
        return false;
      }

      final activeSessionId = sessionId ?? _todaySessionId(uid);
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );
      await _writeLocation(
        uid: uid,
        sessionId: activeSessionId,
        position: position,
        source: source,
        forceHistory: forceHistory,
      );
      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return false;
    }
  }

  Future<void> registerBackgroundTracking(
    String uid, {
    required String sessionId,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await Workmanager().registerPeriodicTask(
      _locationTaskName,
      _locationTask,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      frequency: backgroundInterval,
      initialDelay: const Duration(minutes: 1),
      tag: _locationTaskTag,
      inputData: {'uid': uid, 'sessionId': sessionId},
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  Future<void> cancelBackgroundTracking() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Workmanager().cancelByTag(_locationTaskTag);
    } else {
      await Workmanager().cancelAll();
    }
  }

  Future<void> _startForegroundTracking(String uid, String sessionId) async {
    await _stopLocalTracking();

    final settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: movementThresholdMeters.round(),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) {
      unawaited(
        _writeLocation(
          uid: uid,
          sessionId: sessionId,
          position: position,
          source: 'movement',
        ),
      );
    });

    _foregroundTimer = Timer.periodic(foregroundInterval, (_) {
      unawaited(getLocation(uid, sessionId: sessionId, source: 'foreground'));
    });
  }

  Future<void> _stopLocalTracking() async {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _writeLocation({
    required String uid,
    required String sessionId,
    required Position position,
    required String source,
    bool forceHistory = false,
  }) async {
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);
    final formattedTime = DateFormat('hh:mma dd/MM/yyyy').format(now);
    final locationData = {
      'uid': uid,
      'sessionId': sessionId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'speed': position.speed,
      'heading': position.heading,
      'source': source,
      'isTrackingActive': true,
      'status': 'active',
      'updatedAt': timestamp,
      'update': formattedTime,
    };

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);
    final latestRef = _firestore.collection('employee_locations').doc(uid);
    final sessionRef = userRef.collection('work_sessions').doc(sessionId);

    batch.set(
        userRef,
        {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'locationAccuracy': position.accuracy,
          'locationUpdatedAt': timestamp,
          'locationTrackingActive': true,
          'workSessionId': sessionId,
          'workDayStatus': 'active',
          'update': formattedTime,
        },
        SetOptions(merge: true));
    batch.set(latestRef, locationData, SetOptions(merge: true));
    batch.set(
        sessionRef,
        {
          'uid': uid,
          'sessionId': sessionId,
          'status': 'active',
          'lastLocationAt': timestamp,
          'lastUpdate': formattedTime,
        },
        SetOptions(merge: true));

    if (forceHistory || await _shouldWriteHistory(now)) {
      final historyRef = _firestore
          .collection('employee_location_history')
          .doc(uid)
          .collection('points')
          .doc();
      batch.set(historyRef, {
        ...locationData,
        'createdAt': timestamp,
      });
    }

    await batch.commit();
  }

  Future<bool> _shouldWriteHistory(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final lastIso = prefs.getString(_prefsLastHistoryWriteKey);
    final lastWrite = lastIso == null ? null : DateTime.tryParse(lastIso);

    if (lastWrite != null && now.difference(lastWrite) < historyInterval) {
      return false;
    }

    await prefs.setString(_prefsLastHistoryWriteKey, now.toIso8601String());
    return true;
  }

  Future<void> _writeSessionState({
    required String uid,
    required String sessionId,
    required bool isActive,
    required String status,
  }) async {
    final now = DateTime.now();
    final data = {
      'uid': uid,
      'sessionId': sessionId,
      'isTrackingActive': isActive,
      'status': status,
      'updatedAt': Timestamp.fromDate(now),
      'update': DateFormat('hh:mma dd/MM/yyyy').format(now),
    };

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);
    final latestRef = _firestore.collection('employee_locations').doc(uid);
    final sessionRef = userRef.collection('work_sessions').doc(sessionId);

    batch.set(
        userRef,
        {
          'locationTrackingActive': isActive,
          'workDayStatus': status,
          'workSessionId': isActive ? sessionId : null,
          'update': data['update'],
          if (!isActive) 'workDayEndedAt': data['updatedAt'],
        },
        SetOptions(merge: true));
    batch.set(latestRef, data, SetOptions(merge: true));
    batch.set(
        sessionRef,
        {
          'uid': uid,
          'sessionId': sessionId,
          'status': status,
          if (isActive) 'startedAt': FieldValue.serverTimestamp(),
          if (!isActive) 'endedAt': FieldValue.serverTimestamp(),
          'updatedAt': data['updatedAt'],
        },
        SetOptions(merge: true));

    await batch.commit();
  }

  String _todaySessionId(String uid) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    return '${uid}_$date';
  }
}
