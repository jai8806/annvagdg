import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isLoading; // true only during initial prefs read
  final bool isAuthenticated;
  final String? role;
  final String? phoneNumber;
  final String? userId;
  final bool isVerifying;
  final String? pendingRole;

  const AuthState({
    this.isLoading = true, // starts true
    this.isAuthenticated = false,
    this.role,
    this.phoneNumber,
    this.userId,
    this.isVerifying = false,
    this.pendingRole,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? role,
    String? phoneNumber,
    String? userId,
    bool? isVerifying,
    String? pendingRole,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userId: userId ?? this.userId,
      isVerifying: isVerifying ?? this.isVerifying,
      pendingRole: pendingRole ?? this.pendingRole,
    );
  }
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Start loading, then immediately check prefs async
    _initFromPrefs();
    return const AuthState(isLoading: true);
  }

  Future<void> _initFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      final role = prefs.getString('auth_role');
      if (role != null) {
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          role: role,
          phoneNumber: prefs.getString('auth_phone'),
          userId: prefs.getString('auth_userId'),
        );
      } else {
        state = const AuthState(isLoading: false, isAuthenticated: false);
      }
    } catch (_) {
      // Fail open into demo flow instead of hanging startup.
      state = const AuthState(isLoading: false, isAuthenticated: false);
    }
  }

  void sendOtp(String phone) {
    state = state.copyWith(phoneNumber: phone, isVerifying: true);
  }

  void verifyOtp(String otp) {
    if (otp.length == 6) {
      state = state.copyWith(isVerifying: false);
    }
  }

  void setPendingRole(String role) {
    state = state.copyWith(pendingRole: role);
  }

  Future<void> signIn(String role) async {
    final phone = state.phoneNumber ?? '0000000000';
    final userId = 'mock_$phone';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_role', role);
    await prefs.setString('auth_phone', phone);
    await prefs.setString('auth_userId', userId);

    state = AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: role,
      phoneNumber: phone,
      userId: userId,
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState(isLoading: false, isAuthenticated: false);
  }

  Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    state = AuthState(
      isLoading: false,
      isAuthenticated: true, // still logged in
      phoneNumber: state.phoneNumber,
      role: null, // just cleared
      userId: state.userId,
    );
  }

  void incrementRescues(double kg) {
    // mock for MVP
  }
}
