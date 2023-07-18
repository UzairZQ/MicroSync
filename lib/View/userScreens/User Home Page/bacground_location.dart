 import 'package:workmanager/workmanager.dart';

void getBackgroundLocation(String userid) async {
    const task = 'provideBGLoc';
    Map<String, dynamic> uid = {'uid': userid};
    Workmanager().registerPeriodicTask('locationTask', task,
        backoffPolicy: BackoffPolicy.linear,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 5),
        tag: 'location',
        inputData: uid,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ));
  }