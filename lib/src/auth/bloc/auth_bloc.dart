import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hy_tutorial/src/auth/model/login_model.dart';
import 'package:hy_tutorial/src/auth/repository/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {\
  final _authRepo = AuthRepo();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginPressed>(_loggingIn);
  }

  FutureOr<void> _loggingIn(AuthEvent event, Emitter<AuthState> emit) async {
    if (event is AuthLoginPressed) {
      emit(AuthLoading());
      await _authRepo.login().onError((error, stackTrace) => emit(AuthLoggedOutError())).then((value) {
        LoginModel loginModel = LoginModel.fromJson(value);
      });
    }
  }
}
