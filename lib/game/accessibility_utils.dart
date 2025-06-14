import 'package:flutter/material.dart';

class Accessibility {
  static Widget semanticButton({
    required Widget child,
    required String label,
    required VoidCallback onPressed,
    Key? key,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      child: ExcludeSemantics(
        child: ElevatedButton(
          key: key,
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }

  static Widget semanticFAB({
    required Widget child,
    required String label,
    required VoidCallback onPressed,
    Key? key,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      child: ExcludeSemantics(
        child: FloatingActionButton(
          key: key,
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
