import 'package:flutter/material.dart';

class TestSignInScreen extends StatelessWidget {
  const TestSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bienvenido'),
            Text('Aprende a tu ritmo'),
            _GoogleSignInButton(),
          ],
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Botón: Iniciar sesión con Google',
      button: true,
      container: true,
      child: ExcludeSemantics(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Continuar con Google'),
        ),
      ),
    );
  }
}
