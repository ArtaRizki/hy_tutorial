import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/auth/model/login_model.dart';
import 'package:hy_tutorial/src/auth/repository/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _authRepo = AuthRepo();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginPressed>(_loggingIn);
    on<AuthUsernameChanged>(_onUsernameChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
  }

  void _onUsernameChanged(
    AuthUsernameChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthState(username: event.username));
  }

  void _onPasswordChanged(
    AuthPasswordChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthState(username: event.password));
  }

  FutureOr<void> _loggingIn(AuthEvent event, Emitter<AuthState> emit) async {
    if (event is AuthLoginPressed) {
      emit(AuthLoading());
      await _authRepo.login(event.username, event.password).then((value) {
        emit(AuthLoggedIn());
      }).onError((e, s) {
        emit(AuthLoggedInError());
      });
    }
  }
}
