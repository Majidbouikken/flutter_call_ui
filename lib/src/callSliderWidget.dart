import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

class Call extends StatefulWidget {
  final Function onAccept;
  final Function onReject;
  final Widget aboveChild;
  final Widget belowChild;
  final Color color;
  final Color acceptColor;
  final Color rejectColor;
  final IconData icon;
  final IconData acceptIcon;
  final IconData rejectIcon;

  const Call(
      {Key key,
        this.onAccept,
        this.onReject,
        this.aboveChild,
        this.belowChild,
        this.color = Colors.white,
        this.acceptColor = Colors.green,
        this.rejectColor = Colors.redAccent,
        this.icon = Icons.ring_volume,
        this.acceptIcon = Icons.call,
        this.rejectIcon = Icons.call_end})
      : super(key: key);

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> with SingleTickerProviderStateMixin {
  bool greenSize, redSize;

  @override
  void initState() {
    super.initState();
    greenSize = false;
    redSize = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (widget.aboveChild == null)
                  ? SizedBox(
                height: 0,
              )
                  : widget.aboveChild,
              SizedBox(
                height: 16,
              ),
              Container(
                height: 80,
                width: 300,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 80,
                        width: 80,
                        child: Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            curve: Curves.easeInOutCubic,
                            width: redSize ? 80 : 56,
                            height: redSize ? 80 : 56,
                            decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(40)),
                            child: Icon(
                              widget.rejectIcon,
                              color: widget.rejectColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 80,
                        width: 80,
                        child: Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            curve: Curves.easeInOutCubic,
                            width: greenSize ? 80 : 56,
                            height: greenSize ? 80 : 56,
                            decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(40)),
                            child: Icon(
                              widget.acceptIcon,
                              color: widget.acceptColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Slider(
                      onAccept: widget.onAccept,
                      onReject: widget.onReject,
                      color: widget.color,
                      acceptColor: widget.acceptColor,
                      rejectColor: widget.rejectColor,
                      icon: widget.icon,
                      onDragUpdateGreen: () {
                        if (greenSize == false)
                          setState(() {
                            greenSize = true;
                            print(greenSize);
                          });
                        else if (greenSize == true)
                          setState(() {
                            greenSize = false;
                            print(greenSize);
                          });
                      },
                      onDragUpdateRed: () {
                        if (redSize == false)
                          setState(() {
                            redSize = true;
                            print(redSize);
                          });
                        else if (redSize == true)
                          setState(() {
                            redSize = false;
                            print(redSize);
                          });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              (widget.belowChild == null)
                  ? SizedBox(
                height: 0,
              )
                  : widget.belowChild,
            ],
          )),
    );
  }
}

class Slider extends StatefulWidget {
  final Function onAccept;
  final Function onReject;
  final Function onDragUpdateGreen;
  final Function onDragUpdateRed;
  final Color color;
  final Color acceptColor;
  final Color rejectColor;
  final ValueChanged<double> valueChanged;
  final IconData icon;

  Slider(
      {this.onAccept,
        this.onReject,
        this.onDragUpdateGreen,
        this.onDragUpdateRed,
        this.color,
        this.acceptColor,
        this.rejectColor,
        this.valueChanged,
        this.icon});

  @override
  SliderState createState() {
    return new SliderState();
  }
}

class SliderState extends State<Slider> {
  ValueNotifier<double> valueListener = ValueNotifier(.5);
  bool greenSize;
  bool redSize;

  @override
  void initState() {
    valueListener.addListener(notifyParent);
    greenSize = true;
    redSize = true;
    super.initState();
  }

  void notifyParent() {
    if (widget.valueChanged != null) {
      widget.valueChanged(valueListener.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: 300,
      child: Builder(
        builder: (context) {
          final handle = GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (valueListener.value != 1 && valueListener.value != 0) {
                valueListener.value = (valueListener.value +
                    details.delta.dx / context.size.width)
                    .clamp(.0, 1.0);
                if ((valueListener.value > 0.8) && greenSize) {
                  widget.onDragUpdateGreen();
                  greenSize = false;
                } else if ((valueListener.value < 0.8) && !greenSize) {
                  widget.onDragUpdateGreen();
                  greenSize = true;
                }
                if ((valueListener.value < 0.2) && redSize) {
                  widget.onDragUpdateRed();
                  redSize = false;
                } else if ((valueListener.value > 0.2) && !redSize) {
                  widget.onDragUpdateRed();
                  redSize = true;
                }
              }
            },
            onHorizontalDragEnd: (details) {
              if (valueListener.value > 0.8) {
                valueListener.value = 1.0;
                widget.onAccept();
              } else if (valueListener.value < 0.2) {
                valueListener.value = 0.0;
                widget.onReject();
              } else
                valueListener.value = 0.5;
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                      color: (() {
                        if ((greenSize == true) && (redSize == false))
                          return widget.rejectColor;
                        else if ((redSize == true) && (greenSize == false))
                          return widget.acceptColor;
                        else
                          return widget.color;
                      }()),
                      width: 2)),
              child: Icon(
                widget.icon,
                color: (() {
                  if ((greenSize == true) && (redSize == false))
                    return widget.rejectColor;
                  else if ((redSize == true) && (greenSize == false))
                    return widget.acceptColor;
                  else
                    return widget.color;
                }()),
                size: ((greenSize == false) || (redSize == false)) ? 0 : 36,
              ),
            ),
          );

          return AnimatedBuilder(
            animation: valueListener,
            builder: (context, child) {
              return Align(
                alignment: Alignment(valueListener.value * 2 - 1, .5),
                child: child,
              );
            },
            child: handle,
          );
        },
      ),
    );
  }
}
