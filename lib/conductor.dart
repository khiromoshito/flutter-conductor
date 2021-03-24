import 'package:flutter/material.dart';

class ConductorConfigs {
  static int idcounter = 1;
  static Conductor globalConductor = new Conductor();
}

class ConductorListener {
  Function() callout;
  Duration delay;
  String category;

  ConductorListener({@required this.callout, this.delay, this.category});
}

class Conductor {
  Conductor();
  Conductor.fromListeners(this.listeners);

  Map<int, ConductorListener> listeners = {};
  Map<String, Map<int, ConductorListener>> categories = {};
  Map<String, dynamic> _values = {};

  void update(String key, dynamic value) {
    this._values[key] = value;
    this.broadcast();
  }

  dynamic get(String key) => this._values[key];

  void addListener(int id, ConductorListener listener) {
    this.listeners[id] = listener;

    if (listener.category != null)
      this.categories[listener.category][id] = listener;
  }

  Conductor by(String category) =>
      Conductor.fromListeners(this.categories[category]) ?? {};

  void broadcast() {
    this.listeners.forEach((int id, ConductorListener listener) =>
        Future.delayed(listener.delay, () => listener.callout()));
  }
}

class ConductorBuilder extends StatefulWidget {
  @override
  _ConductorBuilderState createState() => _ConductorBuilderState();

  final int id = ConductorConfigs.idcounter++;
  final Conductor conductor;
  final Widget Function(BuildContext context, Conductor conductor) builder;
  final String category;
  final Duration delay;

  ConductorBuilder(
      {this.conductor, @required this.builder, this.category, this.delay});
}

class _ConductorBuilderState extends State<ConductorBuilder> {
  Function() callout = () {};

  @override
  void initState() {
    callout = () => setState(() {});

    (widget.conductor ?? ConductorConfigs.globalConductor).addListener(
        widget.id,
        ConductorListener(
            callout: callout,
            delay: widget.delay ?? Duration.zero,
            category: widget.category));

    super.initState();
  }

  @override
  void dispose() {
    callout = () {};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.conductor);
  }
}
