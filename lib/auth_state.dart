part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final SpotifyUser user;

  Authenticated(this.user);
}

class AuthenticationRequired extends AuthState {}

class AuthenticationFailed extends AuthState {
  final String message;

  AuthenticationFailed(this.message);
}
