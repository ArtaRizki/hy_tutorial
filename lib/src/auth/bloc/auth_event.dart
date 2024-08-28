part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthLoginPressed extends AuthEvent {
  const AuthLoginPressed(this.username, this.password);

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}

final class AuthUsernameChanged extends AuthEvent {
  const AuthUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

final class AuthPasswordChanged extends AuthEvent {
  const AuthPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class AuthLogoutPressed extends AuthEvent {}
