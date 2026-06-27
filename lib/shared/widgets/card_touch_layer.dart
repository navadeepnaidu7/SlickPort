import 'dart:async';

import 'package:flutter/material.dart';

/// Pointer-based touch layer for wallet cards.
///
/// Tilt is driven through a [Listener] so vertical swipes reach the parent
/// [PageView] instead of being captured by a pan recognizer.
class CardTouchLayer extends StatefulWidget {
  const CardTouchLayer({
    super.key,
    required this.child,
    required this.tiltX,
    required this.tiltY,
    required this.onTap,
    this.onLongPress,
    this.onDragStateChanged,
    this.tapSlop = 18,
  });

  final Widget child;
  final ValueNotifier<double> tiltX;
  final ValueNotifier<double> tiltY;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onDragStateChanged;
  final double tapSlop;

  @override
  State<CardTouchLayer> createState() => _CardTouchLayerState();
}

class _CardTouchLayerState extends State<CardTouchLayer> {
  static const double _scrollDominanceThreshold = 10;
  static const double _tapTravelCap = 8;

  Offset? _downPosition;
  double _verticalTravel = 0;
  double _horizontalTravel = 0;
  bool _scrollMode = false;
  bool _dragging = false;
  Timer? _longPressTimer;
  bool _longPressTriggered = false;

  void _setDragging(bool value) {
    if (_dragging == value) return;
    _dragging = value;
    widget.onDragStateChanged?.call(value);
  }

  void _resetTilt() {
    widget.tiltX.value = 0;
    widget.tiltY.value = 0;
  }

  void _onPointerDown(PointerDownEvent event) {
    _downPosition = event.localPosition;
    _verticalTravel = 0;
    _horizontalTravel = 0;
    _scrollMode = false;
    _longPressTriggered = false;
    _setDragging(false);
    _longPressTimer?.cancel();
    if (widget.onLongPress == null) return;
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      if (_scrollMode || _dragging) return;
      _longPressTriggered = true;
      widget.onLongPress!();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    _verticalTravel += event.delta.dy.abs();
    _horizontalTravel += event.delta.dx.abs();

    if (!_scrollMode &&
        _verticalTravel > _scrollDominanceThreshold &&
        _verticalTravel > _horizontalTravel * 1.15) {
      _scrollMode = true;
      _longPressTimer?.cancel();
      _resetTilt();
      _setDragging(false);
      return;
    }
    if (_scrollMode) return;

    if (_verticalTravel > 2 || _horizontalTravel > 2) {
      _longPressTimer?.cancel();
    }

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Size size = box.size;
    _setDragging(true);
    widget.tiltX.value =
        ((event.localPosition.dy / size.height) - 0.5).clamp(-0.5, 0.5);
    widget.tiltY.value =
        -((event.localPosition.dx / size.width) - 0.5).clamp(-0.5, 0.5);
  }

  void _onPointerEnd(PointerEvent event) {
    _longPressTimer?.cancel();
    _resetTilt();

    if (!_scrollMode &&
        !_longPressTriggered &&
        _downPosition != null &&
        event is PointerUpEvent) {
      final double distance =
          (event.localPosition - _downPosition!).distance;
      if (distance < widget.tapSlop &&
          _verticalTravel < _tapTravelCap &&
          _horizontalTravel < _tapTravelCap) {
        widget.onTap();
      }
    }

    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _setDragging(false);
    });
    _scrollMode = false;
    _downPosition = null;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: widget.child,
    );
  }
}