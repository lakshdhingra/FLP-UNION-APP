import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flp_union_app/core/network/auth_interceptor.dart';
import 'package:flp_union_app/core/storage/secure_storage_service.dart';
import 'package:flp_union_app/features/manager/models/manager_dashboard_dto.dart';
import 'package:flp_union_app/features/manager/providers/engineer_provider.dart';
import 'package:flp_union_app/features/manager/providers/issue_provider.dart';
import 'package:flp_union_app/features/manager/services/engineer_service.dart';
import 'package:flp_union_app/features/manager/services/issue_service.dart';
import 'package:flp_union_app/core/network/api_client.dart';
import 'package:flp_union_app/shared/models/engineer.dart';
import 'package:flp_union_app/shared/models/issue.dart';

class _FakeSecureStorageService implements SecureStorageService {
  String? accessToken = 'mock_access_token';
  String? refreshToken = 'mock_refresh_token';

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

final _dummyStorage = _FakeSecureStorageService();
final _dummyClient = ApiClient(
  storage: _dummyStorage,
  onUnauthorized: () {},
);

class _ThrowingEngineerService extends EngineerService {
  _ThrowingEngineerService() : super(apiClient: _dummyClient);

  @override
  Future<Engineer> createEngineer(Map<String, dynamic> data) async {
    throw Exception('Mock validation failure');
  }

  @override
  Future<void> deleteEngineer(String id) async {
    throw Exception('Delete rejected by backend');
  }
}

class _ThrowingIssueService extends IssueService {
  _ThrowingIssueService() : super(apiClient: _dummyClient);

  @override
  Future<Issue> createIssue({
    required String type,
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    throw Exception('Issue submission failed: 500 internal error');
  }
}

void main() {
  group('DashboardStats DTO parsing regression tests', () {
    test('handles numeric integers properly', () {
      final json = {
        'totalEngineers': 15,
        'activeEngineers': 10,
        'inactiveEngineers': 5,
        'experienceDistribution': {'0-2': 4, '3-5': 6},
        'designationDistribution': {'Senior': 8, 'Junior': 2},
      };

      final stats = DashboardStats.fromJson(json);
      expect(stats.totalEngineers, 15);
      expect(stats.activeEngineers, 10);
      expect(stats.inactiveEngineers, 5);
      expect(stats.experienceDistribution['0-2'], 4);
      expect(stats.designationDistribution['Senior'], 8);
    });

    test(
        'safely parses string-encoded numbers and nulls without throwing TypeError',
        () {
      final json = {
        'totalEngineers': '25',
        'activeEngineers': null,
        'inactiveEngineers': '10',
        'experienceDistribution': {'0-2': '7', '3-5': null},
        'designationDistribution': {'Lead': '12'},
      };

      final stats = DashboardStats.fromJson(json);
      expect(stats.totalEngineers, 25);
      expect(stats.activeEngineers, 0);
      expect(stats.inactiveEngineers, 10);
      expect(stats.experienceDistribution['0-2'], 7);
      expect(stats.experienceDistribution['3-5'], 0);
      expect(stats.designationDistribution['Lead'], 12);
    });
  });

  group('Mutation Notifiers error rethrow regression tests', () {
    test(
        'EngineerMutationsNotifier rethrows exception when createEngineer fails',
        () async {
      final container = ProviderContainer(
        overrides: [
          engineerServiceProvider.overrideWithValue(_ThrowingEngineerService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(engineerMutationsProvider.notifier);

      expect(
        () async => await notifier.createEngineer({'fullName': 'Test'}),
        throwsA(isA<Exception>()),
      );
    });

    test(
        'EngineerMutationsNotifier rethrows exception when deleteEngineer fails',
        () async {
      final container = ProviderContainer(
        overrides: [
          engineerServiceProvider.overrideWithValue(_ThrowingEngineerService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(engineerMutationsProvider.notifier);

      expect(
        () async => await notifier.deleteEngineer('eng-123'),
        throwsA(isA<Exception>()),
      );
    });

    test('IssueMutationsNotifier rethrows exception when createIssue fails',
        () async {
      final container = ProviderContainer(
        overrides: [
          issueServiceProvider.overrideWithValue(_ThrowingIssueService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(issueMutationsProvider.notifier);

      expect(
        () async => await notifier.createIssue(
          type: 'ISSUE',
          title: 'App crashed',
          description: 'Steps to reproduce...',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthInterceptor headers regression tests', () {
    test(
        'attaches Bearer token and sets application/json for standard JSON requests',
        () async {
      final storage = _FakeSecureStorageService();
      final interceptor = AuthInterceptor(
        storage: storage,
        dio: Dio(),
        onUnauthorized: () {},
      );

      final options = RequestOptions(path: '/api/test');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer mock_access_token');
      expect(options.headers['Content-Type'], 'application/json');
    });

    test('does not overwrite Content-Type when request data is FormData',
        () async {
      final storage = _FakeSecureStorageService();
      final interceptor = AuthInterceptor(
        storage: storage,
        dio: Dio(),
        onUnauthorized: () {},
      );

      final formData = FormData.fromMap({'file': 'dummy'});
      final options = RequestOptions(
        path: '/api/upload',
        data: formData,
      );
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer mock_access_token');
      // Content-Type must remain null so Dio generates multipart/form-data boundary
      expect(options.headers['Content-Type'], isNull);
    });
  });
}
