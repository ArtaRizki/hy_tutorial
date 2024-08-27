part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoggedIn extends AuthState {}

final class AuthLoggedInError extends AuthState {}

final class AuthLoggedOut extends AuthState {}

final class AuthLoggedOutError extends AuthState {}
