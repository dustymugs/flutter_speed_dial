import 'package:flutter/material.dart';

class AnimatedFloatingButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final String tooltip;
  final String heroTag;
	final Size size;
  final double elevation;
  final ShapeBorder shape;
  final Curve curve;

  AnimatedFloatingButton({
    this.visible = true,
    this.onPressed,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.heroTag,
		this.size = const Size.square(75.0),
    this.elevation = 6.0,
    this.shape = const CircleBorder(),
    this.curve = Curves.linear,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    var margin = visible ? 0.0 : 28.0;

    return SizedBox.fromSize(
			size: size,
      child: AnimatedContainer(
          curve: curve,
          margin: EdgeInsets.all(margin),
          duration: Duration(milliseconds: 150),
          width: visible ? size.width : 0.0,
          height: visible ? size.height : 0.0,
          child: GestureDetector(
            onLongPress: onLongPress,
						child: FloatingActionButton(
							child: visible ? child : null,
							backgroundColor: backgroundColor,
							foregroundColor: foregroundColor,
							onPressed: onPressed,
							tooltip: tooltip,
							heroTag: heroTag,
							elevation: elevation,
							highlightElevation: elevation,
							shape: shape,
						),
          ),
      ),
    );
  }
}
