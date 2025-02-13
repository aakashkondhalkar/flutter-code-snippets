// Flutter CustomExpansionTile
///
/// Custom ExpansionTile widget, designed to expand/collapse with animations
/// and customizable styling.
///
/// Author: Aakash Kondhalkar
/// Date: Feb 13, 2025
///

import 'package:flutter/material.dart';
import 'package:shc_flutter_app/DesignSystem/Theme/AppThemeColor.dart';
import 'package:shc_flutter_app/DesignSystem/TypographyGuide/AppTextStyles.dart';

// Controller class to manage the expansion and collapse actions of the tile.
class CustomExpansionTileController {
  Function() expand = () {};
  Function() collapse = () {};
}

class CustomExpansionTile extends StatefulWidget {
  // The title of the expansion tile.
  final String title;
  // Optional leading widget (icon or image) to display next to the title.
  final Widget? leading;
  // List of child widgets to show when the tile is expanded.
  final List<Widget> children;
  // Whether the tile should be initially expanded.
  final bool initiallyExpanded;
  // Background color for the children section when expanded.
  final Color childrenBackgroundColor;
  // Padding around the header (title and leading icon).
  final EdgeInsets headerPadding;
  // Padding around the children content.
  final EdgeInsets childrenPadding;
  // Color of the icon when the tile is expanded.
  final Color expandedIconColor;
  // Color of the icon when the tile is collapsed.
  final Color collapseIconColor;
  // Decorations for the collapsed header.
  final ShapeDecoration collapseDecoration;
  // Decorations for the expanded header.
  final ShapeDecoration expandedDecoration;
  // Decorations for the collapsed header.
  final ShapeDecoration collapseHeaderDecoration;
  // Decorations for the expanded header.
  final ShapeDecoration expandedHeaderDecoration;
  // Optional decoration for the children content.
  final ShapeDecoration? childrenDecoration;
  // Custom controller to expand/collapse the tile programmatically.
  final CustomExpansionTileController? controller;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    this.leading,
    required this.children,
    this.initiallyExpanded = false,
    this.childrenBackgroundColor = Colors.white,
    this.headerPadding = const EdgeInsets.all(16),
    this.childrenPadding = const EdgeInsets.all(16),
    this.expandedIconColor = Colors.grey,
    this.collapseIconColor = Colors.black,
    this.collapseDecoration = const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.white, width: 0),
      ),
    ),
    this.expandedDecoration = const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.white, width: 0),
      ),
    ),
    this.collapseHeaderDecoration = const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.grey, width: 1),
      ),
    ),
    this.expandedHeaderDecoration = const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.grey, width: 1),
      ),
    ),
    this.childrenDecoration,
    this.controller,
  }) : super(key: key);

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _arrowRotation;

  late final Tween<double> _sizeTween;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sizeTween = Tween(begin: 0.0, end: 1);

    _arrowRotation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);

    if (_isExpanded) {
      _controller.value = 1.0;
    }

    // Provide the controller to the parent widget
    if (widget.controller != null) {
      widget.controller!.expand = _expand;
      widget.controller!.collapse = _collapse;
    }
  }

  void _expand() {
    _controller.forward();
    setState(() {
      _isExpanded = true;
    });
  }

  void _collapse() {
    _controller.reverse();
    setState(() {
      _isExpanded = false;
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_controller.isDismissed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          _isExpanded ? widget.expandedDecoration : widget.collapseDecoration,
      child: Column(
        children: [
          Container(
            decoration: _isExpanded
                ? widget.expandedHeaderDecoration
                : widget.collapseHeaderDecoration,
            child: ListTile(
              leading: widget.leading,
              contentPadding: widget.headerPadding,
              title: Text(
                widget.title,
                style: AppTextStyles.L_m(_isExpanded
                    ? AppThemeColor.accent
                    : AppThemeColor.onSurface),
              ),
              trailing: RotationTransition(
                turns: _arrowRotation,
                child: Image.asset("assets/images/figma/arrow_down.png",
                    width: 22,
                    height: 22,
                    color: _isExpanded
                        ? AppThemeColor.accent
                        : AppThemeColor.onSurface),
              ),
              onTap: _toggleExpansion,
            ),
          ),
          SizeTransition(
            sizeFactor: _sizeTween.animate(_controller),
            child: Container(
              decoration: widget.childrenDecoration,
              margin: const EdgeInsets.only(top: 1),
              padding: widget.childrenPadding,
              child: Column(children: widget.children),
            ),
          ),
        ],
      ),
    );
  }
}
