// Custom ScrollPhysics for paging behavior (e.g., snapping to items like in a carousel or paginated list).
class PagingScrollPhysics extends ScrollPhysics {
  // The size (height or width) of each item in the list that you want to "page" by.
  // (width for Vertical) and (height for Horizontal)
  final double itemDimension;

  const PagingScrollPhysics({
    required this.itemDimension,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  // Applies this custom physics to a scrollable that already has existing physics.
  @override
  PagingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PagingScrollPhysics(
      itemDimension: itemDimension,
      parent: buildParent(ancestor),
    );
  }

  // Converts current scroll position into a page number (can be fractional).
  double _getPage(ScrollMetrics position) {
    return position.pixels / itemDimension;
  }

  // Converts a page number into a scroll offset in pixels.
  double _getPixels(double page) {
    return page * itemDimension;
  }

  // Based on velocity, calculate the "target" page offset to snap to.
  double _getTargetPixels(ScrollMetrics position, double velocity) {
    double page = _getPage(position);

    // If user is scrolling fast enough to be considered a fling, move to the next/previous page.
    if (velocity < -toleranceFor(position).velocity) {
      page -= 0.5; // Scroll left/up
    } else if (velocity > toleranceFor(position).velocity) {
      page += 0.5; // Scroll right/down
    }

    // Round to the nearest page and convert back to pixels.
    return _getPixels(page.roundToDouble());
  }

  // This method defines the physics simulation after the user lifts their finger.
  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If scroll is out of bounds and moving further out, defer to default behavior.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Determine target page offset based on current velocity.
    final double target = _getTargetPixels(position, velocity);

    // If the target is different from the current position, snap to it with a spring animation.
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring, // Uses default spring (bouncy) physics.
        position.pixels, // Start position
        target, // End position
        velocity, // Initial velocity
        tolerance: toleranceFor(position), // Use the context-aware tolerance
      );
    }

    // If already at the correct page, no simulation needed.
    return null;
  }

  // Disables implicit (smooth) scrolling between pages. Required for snapping effect.
  @override
  bool get allowImplicitScrolling => false;
}
