import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';
import '../data/models/user_model.dart';
import 'dart:async';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;
  StreamSubscription<UserModel?>? _userDataSubscription;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.user.listen(
      (User? user) {
        _userDataSubscription?.cancel();
        if (user != null) {
          // Listen to real-time user data updates
          _userDataSubscription = _authRepository
              .getUserDataStream(user.uid)
              .listen(
                (userData) {
                  if (userData != null) {
                    emit(Authenticated(userData));
                  }
                },
                onError: (error) {
                  emit(AuthError("Failed to fetch user data: $error"));
                  emit(Unauthenticated());
                },
              );
        } else {
          emit(Unauthenticated());
        }
      },
      onError: (error) {
        emit(AuthError("Auth state change error: $error"));
        emit(Unauthenticated());
      },
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      await _authRepository.signInWithGoogle();
      // The stream listener in _checkCurrentUser will handle the state update
    } catch (e) {
      emit(AuthError("Login failed"));
      emit(Unauthenticated());
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError("Failed to sign out: $e"));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _userDataSubscription?.cancel();
    return super.close();
  }
}
