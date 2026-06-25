import 'package:micro_pharma/services/location_services.dart';

Future<void> getBackgroundLocation(String userId, {String? sessionId}) async {
  await LocationServices().registerBackgroundTracking(
    userId,
    sessionId: sessionId ?? '${userId}_active',
  );
}
