// Fixed loopback host for local Android development.
// The phone reaches the PC backend via `adb reverse tcp:3000 tcp:3000`,
// so the app always uses http://127.0.0.1:3000/api/v1 (see ApiConstants).
// No LAN IP, no per-machine generated value. Kept for compatibility.
class ApiEnv {
  ApiEnv._();

  static const String host = String.fromEnvironment('API_HOST', defaultValue: '127.0.0.1');
}
