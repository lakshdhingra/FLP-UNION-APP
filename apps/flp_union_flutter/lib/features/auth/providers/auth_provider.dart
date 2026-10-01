import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/auth_user.dart';
import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';
import '../../../shared/models/user_role.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../services/states_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(apiClient: apiClient, storage: storage);
});

final statesServiceProvider = Provider<StatesService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StatesService(apiClient: apiClient);
});

final statesListProvider = FutureProvider<List<StateEntity>>((ref) async {
  final service = ref.watch(statesServiceProvider);
  return service.getAllStates();
});

final districtsListProvider = FutureProvider.family<List<DistrictEntity>, String>((ref, stateId) async {
  if (stateId.isEmpty) return [];
  final service = ref.watch(statesServiceProvider);
  return service.getDistricts(stateId);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState()) {
    hydrate();
  }

  Future<void> hydrate() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    }
  }

  void handleUnauthorized() {
    state = const AuthState(
      isLoading: false,
      isAuthenticated: false,
      user: null,
    );
  }

  Future<UserRole> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final role = await _repository.login(email: email, password: password);
      await hydrate();
      return role;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> registerManager({
    required String fullName,
    required String mobile,
    required String email,
    required String stateId,
    required String districtId,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.registerManager(
        fullName: fullName,
        mobile: mobile,
        email: email,
        stateId: stateId,
        districtId: districtId,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(
      isLoading: false,
      isAuthenticated: false,
      user: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(repository: repo);
  ref.listen<int>(unauthorizedEventProvider, (previous, next) {
    if (next > 0) {
      notifier.handleUnauthorized();
    }
  });
  return notifier;
});
