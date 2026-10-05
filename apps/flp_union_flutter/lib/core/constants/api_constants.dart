abstract class ApiConstants {
  static const String _defaultRemoteBaseUrl = 'http://3.109.49.84/api';

  static String get baseUrl {
    const String overrideUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideUrl.isNotEmpty) {
      return overrideUrl;
    }
    return _defaultRemoteBaseUrl;
  }

  static const String tokenKey = 'flp_access_token';
  static const String refreshTokenKey = 'flp_refresh_token';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String registerManager = '/auth/register/manager';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // State & District endpoints
  static const String states = '/states';

  // Manager endpoints
  static const String managerProfile = '/manager/profile';
  static const String managerDashboard = '/manager/dashboard';
  static const String managerEngineers = '/manager/engineers';
  static const String managerManagers = '/manager/managers';

  // Issues
  static const String issues = '/issues';
  static const String issuesMine = '/issues/mine';

  // Admin endpoints
  static const String adminAnalyticsSummary = '/admin/analytics/summary';
  static const String adminStates = '/admin/states';
  static const String adminDistricts = '/admin/districts';
  static const String adminManagers = '/admin/managers';
  static const String adminEngineers = '/admin/engineers';
  static const String adminIssues = '/admin/issues';
  static const String adminAuditLogs = '/admin/audit-logs';
}
