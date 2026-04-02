class AppConfig {
  const AppConfig._();

  static const appName = 'Pino Mobile';
  static const apiBaseUrl = String.fromEnvironment(
    'PINO_API_BASE_URL',
    defaultValue: 'https://www.rhclaroni.com/api-dev',
  );
  static const socketBaseUrl = String.fromEnvironment(
    'PINO_SOCKET_BASE_URL',
    defaultValue: 'https://www.rhclaroni.com',
  );
  static const socketPath = String.fromEnvironment(
    'PINO_SOCKET_PATH',
    defaultValue: '/api-dev/socket.io',
  );
  static const socketNamespace = String.fromEnvironment(
    'PINO_SOCKET_NAMESPACE',
    defaultValue: '/events',
  );
}
