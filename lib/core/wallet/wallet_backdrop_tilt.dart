import 'package:flutter/material.dart';

/// Shared tilt signal from the active wallet card to the backdrop painter.
class WalletBackdropTilt extends ValueNotifier<Offset> {
  WalletBackdropTilt() : super(Offset.zero);

  bool dragging = false;

  void update({required double tiltX, required double tiltY, required bool isDragging}) {
    dragging = isDragging;
    value = Offset(tiltY, tiltX);
  }

  void reset() {
    dragging = false;
    value = Offset.zero;
  }
}