import 'dart:async';
import 'package:flutter/material.dart';

class SessionService {
  static Timer? _timer;
  static VoidCallback? _onTimeout;
  static bool _active = false;
  static const _timeout = Duration(minutes: 10);

  static void start(VoidCallback onTimeout) {
    _onTimeout = onTimeout;
    if (!_active) {
      _active = true;
      _reset();
    }
  }

  static void reset() {
    if (_active) _reset();
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _onTimeout = null;
    _active = false;
  }

  static void _reset() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      _active = false;
      _onTimeout?.call();
    });
  }
}
