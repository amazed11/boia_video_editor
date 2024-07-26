import 'package:flutter/material.dart';
import 'package:video_editor/src/models/trim_style.dart';
import 'dart:ui' as ui;

class TrimSliderPainter extends CustomPainter {
  const TrimSliderPainter(
    this.rect,
    this.position,
    this.style, {
    this.isTrimming = false,
    this.isTrimmed = false,
    this.image,
  });

  final Rect rect;
  final bool isTrimming, isTrimmed;
  final double position;
  final TrimSliderStyle style;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint background = Paint()..color = style.background;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(style.borderRadius),
    );

    // DRAW LEFT AND RIGHT BACKGROUNDS
    // extract [rect] trimmed area from the canvas
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(style.borderRadius),
          )),
        Path()
          ..addRect(rect)
          ..close(),
      ),
      background,
    );

    canvas.drawPath(
      Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(style.borderRadius),
        )),
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final trimColor = isTrimming
        ? style.onTrimmingColor
        : isTrimmed
            ? style.onTrimmedColor
            : style.lineColor;

    final line = Paint()
      ..color = trimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.lineWidth;

    final edges = Paint()..color = trimColor;

    final double halfLineWidth = style.edgeWidth / 2;
    final double halfHeight = rect.height / 2;

    final centerLeft = Offset(rect.left - halfLineWidth, halfHeight);
    final centerRight = Offset(rect.right + halfLineWidth, halfHeight);

    switch (style.edgesType) {
      case TrimSliderEdgesType.bar:
        paintBar(
          canvas,
          size,
          rrect: rrect,
          line: line,
          edges: edges,
          centerLeft: centerLeft,
          centerRight: centerRight,
          halfLineWidth: halfLineWidth,
        );
        break;
      case TrimSliderEdgesType.circle:
        paintCircle(
          canvas,
          size,
          rrect: rrect,
          line: line,
          edges: edges,
          centerLeft: centerLeft,
          centerRight: centerRight,
        );
        break;
    }
  }

  void paintBar(
    Canvas canvas,
    Size size, {
    required RRect rrect,
    required Paint line,
    required Paint edges,
    required Offset centerLeft,
    required Offset centerRight,
    required double halfLineWidth,
  }) {
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromPoints(
          rect.topLeft + const Offset(0, 1),
          rect.topRight - Offset(-4.0, style.lineWidth) + const Offset(0, 1),
        ))
        ..addRect(
          Rect.fromPoints(
            rect.bottomRight +
                Offset(4.0, style.lineWidth) -
                const Offset(0, 1),
            rect.bottomLeft - const Offset(0, 1),
          ),
        ),
      Paint()..color = Colors.transparent,
    );

    if (image != null) {
      canvas.drawImage(
        image!,
        rect.topLeft + const Offset(-8.0, -3.0),
        Paint(),
      );
      canvas.drawImage(
        image!,
        rect.topRight + const Offset(0.0, -3.0),
        Paint(),
      );
    }

    paintIndicator(canvas, size);
  }

  void paintCircle(
    Canvas canvas,
    Size size, {
    required RRect rrect,
    required Paint line,
    required Paint edges,
    required Offset centerLeft,
    required Offset centerRight,
  }) {
    // DRAW RECT BORDERS
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width + style.edgeWidth,

            ///Make Reactangle more visible
            height: rect.height + style.edgeWidth - 4,
          ),
          Radius.circular(style.borderRadius),
        ),
        line);

    paintIndicator(canvas, size);

    // LEFT CIRCLE
    canvas.drawCircle(centerLeft, style.edgesSize, edges);
    // RIGHT CIRCLE
    canvas.drawCircle(centerRight, style.edgesSize, edges);

    paintIcons(canvas, centerLeft: centerLeft, centerRight: centerRight);
  }

  void paintIndicator(Canvas canvas, Size size) {
    final progress = Paint()
      ..color = style.lineColor
      ..strokeWidth = 1;

    // DRAW VIDEO INDICATOR
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(position - style.positionLineWidth / 2, -style.lineWidth * 4),
          Offset(
            position + style.positionLineWidth / 6,
            size.height + style.lineWidth * 4 + 3,
          ),
        ),
        Radius.circular(style.positionLineWidth),
      ),
      progress,
    );
  }

  void paintIcons(
    Canvas canvas, {
    required Offset centerLeft,
    required Offset centerRight,
  }) {
    final halfIconSize = Offset(style.iconSize / 2, style.iconSize / 2);

    // LEFT ICON
    if (style.leftIcon != null) {
      TextPainter leftArrow = TextPainter(textDirection: TextDirection.rtl);
      leftArrow.text = TextSpan(
        text: String.fromCharCode(style.leftIcon!.codePoint),
        style: TextStyle(
          fontSize: style.iconSize,
          fontFamily: style.leftIcon!.fontFamily,
          color: style.iconColor,
        ),
      );
      leftArrow.layout();
      leftArrow.paint(canvas, centerLeft - halfIconSize);
    }

    // RIGHT ICON
    if (style.rightIcon != null) {
      TextPainter rightArrow = TextPainter(textDirection: TextDirection.rtl);
      rightArrow.text = TextSpan(
        text: String.fromCharCode(style.rightIcon!.codePoint),
        style: TextStyle(
          fontSize: style.iconSize,
          fontFamily: style.rightIcon!.fontFamily,
          color: style.iconColor,
        ),
      );
      rightArrow.layout();
      rightArrow.paint(canvas, centerRight - halfIconSize);
    }
  }

  @override
  bool shouldRepaint(TrimSliderPainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.position != position ||
      oldDelegate.style != style ||
      oldDelegate.isTrimming != isTrimming ||
      oldDelegate.isTrimmed != isTrimmed;

  @override
  bool shouldRebuildSemantics(TrimSliderPainter oldDelegate) => false;
}
