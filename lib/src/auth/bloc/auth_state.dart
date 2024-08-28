part of 'auth_bloc.dart';

final class AuthState extends Equatable {
  final String username;
  final String password;

  const AuthState({this.username = '', this.password = ''});

  AuthState copyWith({
    String? username,
    String? password,
  }) =>
      AuthState(
          username: username ?? this.username,
          password: password ?? this.password);

  @override
  List<Object> get props => [username, password];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoggedIn extends AuthState {}

final class AuthLoggedInError extends AuthState {}

final class AuthLoggedOut extends AuthState {}

final class AuthLoggedOutError extends AuthState {}
