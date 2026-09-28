// AUTO-GENERATED/UPDATED by START_PARABDI_DEV.ps1 - do not edit manually.
// Single source of truth for the PC LAN host used by the physical Android device.
class ApiEnv {
  ApiEnv._();

  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.1.7',
  );
}
