// Flutter Day view calendar
///
/// DayCalendarView used to show events and availabilities day wise
/// We can customize to show events by trainer, by week by section on single day
///
/// Author: Aakash Kondhalkar
/// Date: Feb 10, 2025
///

import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  bool isAfterOrEqual(DateTime other) {
    return isAtSameMomentAs(other) || isAfter(other);
  }

  bool isBeforeOrEqual(DateTime other) {
    return isAtSameMomentAs(other) || isBefore(other);
  }

  bool isBetween({required DateTime from, required DateTime to}) {
    return isAfterOrEqual(from) && isBeforeOrEqual(to);
  }

  bool isBetweenExclusive({required DateTime from, required DateTime to}) {
    return isAfter(from) && isBefore(to);
  }
}

const Color darkGridColor = Colors.grey;
final Color lightGridColor = Colors.grey[300]!;
const Color hourTextColor = Colors.black87;

class DayCalendarView extends StatelessWidget {
  final List<CalendarEvent> events;
  final double heightOfCalendarUI;
  final Function(CalendarEvent? calendarEvent) onTap;

  const DayCalendarView(
      {Key? key,
      required this.events,
      this.heightOfCalendarUI = 1440,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        drawnAvailabilities.clear();
        drawnEvents.clear();
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: heightOfCalendarUI,
            child: Center(
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    // padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(
                                width: 60,
                                child: _TimeColumn(
                                    heightOfCalendarUI: heightOfCalendarUI)),
                            Column(
                              children: [
                                SizedBox(
                                  width: size.width - 60,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        buildCalendarRows(context, size),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCalendarRows(BuildContext context, Size size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth:
            size.width - 60, // Adjust this value based on your layout needs
      ),
      child: Column(
        children: [
          Container(
            height: heightOfCalendarUI,
            padding: const EdgeInsets.only(right: 4),
            color: Colors.grey[200],
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                _GridLines(
                    events: events, heightOfCalendarUI: heightOfCalendarUI),
                _AvailabilityColumn(
                  availabilities:
                      events.where((e) => e.isAvailability).toList(),
                  heightOfCalendarUI: heightOfCalendarUI,
                  onTap: (availability) {
                    onTap(availability);
                  },
                ),
                _EventColumn(
                  events: events.where((e) => !e.isAvailability).toList(),
                  heightOfCalendarUI: heightOfCalendarUI,
                  onTap: (event) {
                    onTap(event);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final double heightOfCalendarUI;

  const _TimeColumn({Key? key, this.heightOfCalendarUI = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a list of time slots
    final timeSlots = <Widget>[];
    for (int i = 0; i < 24 * 2; i++) {
      // 24 hours * 2 for 30-minute intervals
      final hour = i ~/ 2;
      final minute = i % 2 == 0 ? '00' : '30';
      String timeString;
      if (hour > 12) {
        timeString = '${(hour - 12).toString().padLeft(2, '0')} PM';
      } else {
        timeString = '${hour.toString().padLeft(2, '0')} AM';
      }

      timeSlots.add(Container(
        height: heightOfCalendarUI / 48,
        width: 60,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              right: const BorderSide(color: Colors.black87),
              top: BorderSide(
                  color: i == 0 ? darkGridColor : Colors.transparent),
              bottom: BorderSide(
                  color: i % 2 == 0 ? lightGridColor : darkGridColor)),
        ),
        child: Text(
          i % 2 == 0 ? timeString : "",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
      ));
    }

    return Column(
      children: timeSlots,
    );
  }
}

class _GridLines extends StatefulWidget {
  final List<CalendarEvent> events;
  final double heightOfCalendarUI;

  const _GridLines(
      {Key? key, required this.events, this.heightOfCalendarUI = 0})
      : super(key: key);

  @override
  State<_GridLines> createState() => _GridLinesState();
}

class _GridLinesState extends State<_GridLines> {
  @override
  Widget build(BuildContext context) {
    // Create a list of time slots
    final timeSlots = <Widget>[];
    for (int i = 0; i < 24 * 2; i++) {
      timeSlots.add(
        Container(
          height: widget.heightOfCalendarUI / 48,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(
                    color: i == 0 ? darkGridColor : Colors.transparent),
                bottom: BorderSide(
                    color: i % 2 == 0 ? lightGridColor : darkGridColor)),
          ),
          child: const Text(""),
        ),
      );
    }

    return Column(
      children: timeSlots,
    );
  }
}

List<CalendarEvent> drawnAvailabilities = [];
Map<CalendarEvent, int> overLappingAvailabilitiesMap = {};

const double widthOfAvailability = 40;
const double spaceBetweenAvailability = 10;
const double totalSpaceOfAvailabilities =
    widthOfAvailability + spaceBetweenAvailability;

class _AvailabilityColumn extends StatelessWidget {
  final List<CalendarEvent> availabilities;
  final double heightOfCalendarUI;
  final Function(CalendarEvent? availability) onTap;

  const _AvailabilityColumn(
      {required this.availabilities,
      this.heightOfCalendarUI = 0,
      required this.onTap});

  int countOverlappingRanges(List<DateTimeRange> ranges) {
    if (ranges.isEmpty) return 0;

    // Sort ranges by start time
    ranges.sort((a, b) => a.start.compareTo(b.start));

    int overlapCount = 0;
    int currentOverlap = 0;

    // To keep track of end times
    List<DateTime> endTimes = [];

    for (var range in ranges) {
      overlapCount = 0;
      currentOverlap = 0;
      // Remove end times that are before the start of the current range
      endTimes.removeWhere((endTime) =>
          endTime.isAtSameMomentAs(range.start) ||
          endTime.isBeforeOrEqual(range.start));

      // Increase count for every active range
      currentOverlap += endTimes.length;
      endTimes.add(range.end);

      // Track the maximum overlap count
      overlapCount =
          currentOverlap > overlapCount ? currentOverlap : overlapCount;
    }

    return overlapCount;
  }

  @override
  Widget build(BuildContext context) {
    drawnAvailabilities.clear();
    overLappingAvailabilitiesMap.clear();

    return Stack(
      children: [
        ...availabilities
            .where((availability) => availability.time != null)
            .map((availability) {
          final hour = availability.time!.hour;
          final minute = availability.time!.minute;
          final durationMinutes = availability.duration.inMinutes;

          // Calculate the vertical position based on the start time
          final top = (hour * 60 + minute);
          final height = durationMinutes;
          final startTime = availability.time;
          final endTime = availability.time!.add(availability.duration);

          drawnAvailabilities.add(availability);

          var overLappingAvailabilityCount = countOverlappingRanges(
              drawnAvailabilities
                  .map((e) => DateTimeRange(
                      start: e.time!, end: e.time!.add(e.duration)))
                  .toList());

          return Positioned(
            top: top.toDouble(),
            left: totalSpaceOfAvailabilities * overLappingAvailabilityCount,
            //right: MediaQuery.of(context).size.width * 0.5,
            width: widthOfAvailability,
            height: height.toDouble(),
            // Use this for the height of the event
            child: GestureDetector(
              onTap: () {
                onTap(availability);
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: spaceBetweenAvailability),
                decoration: BoxDecoration(
                    color: availability.backgroundColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      )
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    availability.title ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(color: availability.foregroundColor),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

List<CalendarEvent> drawnEvents = [];

class _EventColumn extends StatelessWidget {
  final List<CalendarEvent> events;
  final double heightOfCalendarUI;
  final Function(CalendarEvent? event) onTap;

  const _EventColumn(
      {Key? key,
      this.events = const [],
      this.heightOfCalendarUI = 0,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    drawnEvents.clear();
    return Stack(
      children: [
        ...events.where((event) => event.time != null).map((event) {
          final hour = event.time!.hour;
          final minute = event.time!.minute;
          final durationMinutes = event.duration.inMinutes;

          // Calculate the vertical position based on the start time
          final top = (hour * 60 + minute);
          final height = durationMinutes;
          final startTime = event.time;
          final endTime = event.time!.add(event.duration);

          int availabilityOverLappingWithEventCount =
              drawnAvailabilities.where((old) {
            if (old.time!.isAtSameMomentAs(event.time!) &&
                old.duration.inMinutes == event.duration.inMinutes) {
              return true;
            } else {
              return startTime!.isBetweenExclusive(
                      from: old.time!, to: old.time!.add(old.duration)) ||
                  endTime.isBetweenExclusive(
                      from: old.time!, to: old.time!.add(old.duration));
            }
          }).length;

          var overLappingEventCount = drawnEvents.where((old) {
            if (old.time!.isAtSameMomentAs(event.time!) &&
                old.duration.inMinutes == event.duration.inMinutes) {
              return true;
            } else {
              return startTime!.isBetweenExclusive(
                      from: old.time!, to: old.time!.add(old.duration)) ||
                  endTime.isBetweenExclusive(
                      from: old.time!, to: old.time!.add(old.duration));
            }
          }).length;

          drawnEvents.add(event);

          return Positioned(
            top: top.toDouble(),
            left: 40.0 * overLappingEventCount,
            right: 0,
            height: height.toDouble(),
            // Use this for the height of the event
            child: _eventCard(event, availabilityOverLappingWithEventCount),
          );
        }).toList(),
      ],
    );
  }

  Widget _eventCard(
      CalendarEvent event, int availabilityOverLappingWithEventCount) {
    return GestureDetector(
      onTap: () {
        onTap(event);
      },
      child: Container(
        margin: EdgeInsets.only(
            left: totalSpaceOfAvailabilities *
                availabilityOverLappingWithEventCount),
        decoration: BoxDecoration(
            color: event.backgroundColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              )
            ],
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Text(
          event.title ?? "",
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(color: event.foregroundColor),
        ),
      ),
    );
  }
}

class CalendarEvent<T> {
  DateTime? time;
  final String? title;
  final Duration duration; // Add duration to the CalendarEvent class
  final bool isAvailability;
  final Color foregroundColor;
  final Color backgroundColor;
  final T? data;

  CalendarEvent({
    required this.time,
    required this.title,
    required this.duration,
    this.isAvailability = false,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.data,
  });
}
