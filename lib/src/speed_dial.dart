import 'package:flutter/material.dart';

import 'animated_child.dart';
import 'animated_floating_button.dart';
import 'background_overlay.dart';
import 'speed_dial_child.dart';

/// Builds the Speed Dial
class SpeedDial extends StatefulWidget {
  /// Children buttons, from the lowest to the highest.
  final List<SpeedDialChild> children;

  /// Used to get the button hidden on scroll. See examples for more info.
  final bool visible;

  /// The curve used to animate the button on scrolling.
  final Curve curve;

  final String tooltip;
  final String heroTag;
  final Color backgroundColor;
	final Color endBackgroundColor;
  final Color foregroundColor;
	final Size size;
  final double elevation;
  final ShapeBorder shape;

  final double marginRight;
  final double marginBottom;

  /// The color of the background overlay.
  final Color overlayColor;

  /// The opacity of the background overlay when the dial is open.
  final double overlayOpacity;

  /// The animated icon to show as the main button child. If this is provided the [child] is ignored.
  final AnimatedIconData animatedIcon;

  /// The theme for the animated icon.
  final IconThemeData animatedIconTheme;

  /// The child of the main button, ignored if [animatedIcon] is non [null].
  final Widget child;

  /// The endchild of the main button, ignored if [animatedIcon] is non [null].
  final Widget endChild;

  /// Executed when the dial is opened.
  final VoidCallback onOpen;

  /// Executed when the dial is closed.
  final VoidCallback onClose;

  /// Executed when the dial is pressed. If given, the dial only opens on long press!
  final VoidCallback onPressed;

  /// If true user is forced to close dial manually by tapping main button. WARNING: If true, overlay is not rendered.
  final bool closeManually;

  /// The speed of the animation
  final int animationSpeed;

  SpeedDial({
    this.children = const [],
    this.visible = true,
    this.backgroundColor,
    this.endBackgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
		this.size = const Size.square(75.0),
    this.overlayOpacity = 0.8,
    this.overlayColor = Colors.white,
    this.tooltip,
    this.heroTag,
    this.animatedIcon,
    this.animatedIconTheme,
    this.child,
    this.endChild,
    this.marginBottom = 16,
    this.marginRight = 16,
    this.onOpen,
    this.onClose,
    this.closeManually = false,
    this.shape = const CircleBorder(),
    this.curve = Curves.linear,
    this.onPressed,
    this.animationSpeed = 150
  });

  @override
  _SpeedDialState createState() => _SpeedDialState();
}

class _SpeedDialState extends State<SpeedDial> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<Color> buttonColor;

  double singleChildrenTween;
  bool speedDialOpen = false;

  @override
  void initState() {
    super.initState();

		singleChildrenTween = 1.0 / widget.children.length;

    animationController = AnimationController(
      duration: calculateMainControllerDuration(),
      vsync: this,
    )
			..addListener(() {
				if (mounted)
				 	setState(() {});
			});

		if (widget.backgroundColor != null && widget.endBackgroundColor != null) {
			buttonColor = ColorTween(
				begin: widget.backgroundColor,
				end: widget.endBackgroundColor,
			).animate(
				CurvedAnimation(
					parent: animationController,
					curve: Interval(
						0.0,
						1.0,
						curve: Curves.linear,
					),
				)
			);
		}
  }

  Duration calculateMainControllerDuration() {
		return Duration(
			milliseconds: widget.animationSpeed + widget.children.length * (widget.animationSpeed / 5).round()
		);
	}

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SpeedDial oldWidget) {
    if (oldWidget.children.length != widget.children.length) {
      animationController.duration = calculateMainControllerDuration();
			singleChildrenTween = 1.0 / widget.children.length;
		}

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      buildMainButton(),
    ];

    if (!widget.closeManually)
			children.insert(0, buildOverlay());

    return Stack(
      alignment: Alignment.bottomRight,
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: children,
    );
  }

  Widget buildOverlay() {
    return Positioned(
      right: -16.0,
      bottom: -16.0,
      top: speedDialOpen ? 0.0 : null,
      left: speedDialOpen ? 0.0 : null,
      child: GestureDetector(
        onTap: toggleChildren,
        child: BackgroundOverlay(
          animation: animationController,
          color: widget.overlayColor,
          opacity: widget.overlayOpacity,
        ),
      ),
    );
  }

  Widget buildMainButton() {
    var child;
	 
		if (widget.animatedIcon != null) {
			child = AnimatedIcon(
				icon: widget.animatedIcon,
				progress: animationController,
				color: widget.animatedIconTheme?.color,
				size: widget.animatedIconTheme?.size,
			);
		}
		else if (widget.endChild != null) {
			child = AnimatedSwitcher(
				duration: animationController.duration * widget.children.length,
				child: speedDialOpen ? widget.endChild : widget.child,
			);
		}
		else
			child = widget.child;

    var fabChildren = buildChildren();

    var animatedFloatingButton = AnimatedFloatingButton(
      visible: widget.visible,
      tooltip: widget.tooltip,
      backgroundColor: buttonColor?.value ?? widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      elevation: widget.elevation,
      onPressed: (speedDialOpen || widget.onPressed == null) ? toggleChildren : widget.onPressed,
      onLongPress: toggleChildren,
      child: child,
      heroTag: widget.heroTag,
      shape: widget.shape,
      curve: widget.curve,
    );

    return Container(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.end,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: List.from(fabChildren)
					..add(
						Container(
							margin: EdgeInsets.only(top: 8.0),
							child: animatedFloatingButton,
						),
					),
			),
    );
  }

  List<Widget> buildChildren() {
    return widget.children
			.map(buildChild)
			.toList()
			.reversed
			.toList();
  }

	Widget buildChild(SpeedDialChild child) {
		final index = widget.children.indexOf(child);
		final childSize = child.size ?? widget.size * 0.9;
		final childAnimation = Tween(begin: 0.0, end: childSize.height).animate(
			CurvedAnimation(
				parent: animationController,
				curve: Interval(0, singleChildrenTween * (index + 1)),
			),
		);

		final marginAlignment = EdgeInsets.only(right: widget.size.width / 2.0 - childSize.width / 2.0);

		return AnimatedChild(
			animation: childAnimation,
			index: index,
			visible: speedDialOpen,
			backgroundColor: child.backgroundColor,
			foregroundColor: child.foregroundColor,
			size: childSize,
			marginAlignment: marginAlignment,
			elevation: child.elevation,
			child: child.child,
			label: child.label,
			labelStyle: child.labelStyle,
			labelBackgroundColor: child.labelBackgroundColor,
			labelWidget: child.labelWidget,
			onTap: child.onTap,
			toggleChildren: () {
				if (!widget.closeManually)
					toggleChildren();
			},
			shape: child.shape,
			heroTag: widget.heroTag != null ? '${widget.heroTag}-child-$index' : null,
		);
	}


  void toggleChildren() {
    speedDialOpen = !speedDialOpen;

    if (speedDialOpen && widget.onOpen != null)
		 	widget.onOpen();

    _performAnimation();

    if (!speedDialOpen && widget.onClose != null)
		 	widget.onClose();
  }

  void _performAnimation() {
    if (!mounted)
		 	return;

    if (speedDialOpen)
      animationController.forward();
    else
      animationController.reverse();
  }
}
