class EnvironmentConfig {
  static const isDev = bool.fromEnvironment('IS_DEV', defaultValue: false);
  static const backEndUrl =
      String.fromEnvironment('BACK_END_URL', defaultValue: '');
  static const authStatePrefix = String.fromEnvironment(
    'AUTH_STATE_PREFIX',
    defaultValue: 'Auth',
  );
}
