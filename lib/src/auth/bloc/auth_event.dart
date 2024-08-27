part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthLoginPressed extends AuthEvent {}

final class AuthLogoutPressed extends AuthEvent {}
