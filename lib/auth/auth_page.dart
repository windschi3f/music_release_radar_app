import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthenticationFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) => Scaffold(
        body: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is Authenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${state.user.displayName}!'),
            Text('Followers: ${state.user.followerCount}'),
          ],
        ),
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () => context.read<AuthCubit>().authenticate(),
          child: const Text('Login with Spotify'),
        ),
      );
    }
  }
}
