import 'package:flutter/material.dart';

/// Extension on [Offset] to provide scaling functionalities.
///
/// This extension allows for scaling an [Offset] to and from a standard canvas size.
/// The standard canvas size is defined by [standardWidth] and [standardHeight].
extension OffsetExtensions on Offset {
  /// Standard width of the canvas.
  static const double standardWidth = 800;

  /// Standard height of the canvas.
  static const double standardHeight = 600;

  /// Scales the current [Offset] to a standard canvas size.
  ///
  /// This method scales the current offset coordinates (dx, dy) from the current
  /// device canvas size to a predefined standard canvas size. This is useful for
  /// maintaining consistency of coordinates across different devices.
  ///
  /// The scaling is based on the ratio of the standard canvas size to the actual
  /// size of the device canvas.
  ///
  /// [deviceCanvasSize] is the size of the canvas on the current device.
  ///
  /// Returns a new [Offset] that is scaled to the standard canvas size.
  Offset scaleToStandard(Size deviceCanvasSize) {
    final scaleX = standardWidth / deviceCanvasSize.width;
    final scaleY = standardHeight / deviceCanvasSize.height;

    return Offset(dx * scaleX, dy * scaleY);
  }

  /// Scales the current [Offset] from a standard canvas size to the device canvas size.
  ///
  /// This method is the inverse of [scaleToStandard]. It scales the current offset
  /// coordinates (dx, dy) from the standard canvas size back to the device canvas size.
  /// This is particularly useful when rendering coordinates that were captured
  /// on a device with a different resolution.
  ///
  /// The scaling is based on the ratio of the device canvas size to the standard
  /// canvas size.
  ///
  /// [deviceCanvasSize] is the size of the canvas on the current device.
  ///
  /// Returns a new [Offset] that is scaled from the standard canvas size to
  /// the device's canvas size.
  Offset scaleFromStandard(Size deviceCanvasSize) {
    final scaleX = deviceCanvasSize.width / standardWidth;
    final scaleY = deviceCanvasSize.height / standardHeight;

    return Offset(dx * scaleX, dy * scaleY);
  }
}
