import 'package:flutter/material.dart';

class ConductorConfigs {
  static int idcounter = 1;
  static Conductor globalConductor = new Conductor();
}

Conductor getGlobalConductor() => ConductorConfigs.globalConductor;

class ConductorListener {
  Function() callout;
  Duration delay;
  String category;

  ConductorListener({@required this.callout, this.delay, this.category});
}

class ConductorValue {
  dynamic value;

  ConductorValue(this.value);

  void update(dynamic value) => this.value = value;
  void getValue() => this.value;
}

class Conductor {
  Conductor([this._values]) {
    if (this._values == null) this._values = {};
  }

  Conductor.fromListeners(this.listeners, [this._values]) {
    if (this._values == null) this._values = {};
  }

  Conductor.fromOnly(String id, ConductorListener listener, [this._values]) {
    this.listeners[id] = listener;

    if (listener.category != null) {
      if (this.categories[listener.category] != null)
        this.categories[listener.category][id] = listener;
      else
        this.categories[listener.category] = {id: listener};
    }

    if (this._values == null) this._values = {};
  }

  Map<String, ConductorListener> listeners = {};
  Map<String, Map<String, ConductorListener>> categories = {};
  Map<String, ConductorValue> _values = {};

  void update(String key, dynamic value) {
    if (this._values[key] != null) {
      this._values[key].update(value);
    } else {
      this._values.addAll({key: ConductorValue(value)});
    }

    this.broadcast();
  }

  dynamic get(String key) => this._values[key].getValue();

  void addListener(String id, ConductorListener listener) {

    this.listeners[id] = listener;

    if (listener.category != null) {
      if (this.categories[listener.category] != null)
        this.categories[listener.category][id] = listener;
      else
        this.categories[listener.category] = {id: listener};
    }
  }

  Conductor by(String category) => Conductor.fromListeners(
        this.categories[category] ?? {}, this._values);
  

  Conductor only(String id) => this.listeners[id] != null
        ? Conductor.fromOnly(id, this.listeners[id], this._values)
        : Conductor(this._values);
  

  void broadcast() {
    this.listeners.forEach((String id, ConductorListener listener) =>
        Future.delayed(listener.delay, () => listener.callout()));
  }
}

class ConductorBuilder extends StatefulWidget {
  @override
  _ConductorBuilderState createState() => _ConductorBuilderState();

  final String id;
  final Conductor conductor;
  final Widget Function(BuildContext context, Conductor conductor) builder;
  final String category;
  final Duration delay;

  ConductorBuilder(
      {this.conductor,
      this.id,
      @required this.builder,
      this.category,
      this.delay});
}

class _ConductorBuilderState extends State<ConductorBuilder> {
  Function() callout = () {};

  String id;
  Conductor conductor;

  @override
  void initState() {
    callout = () => setState(() {});

    this.id = widget.id ??
        ("conductorbuilder-" + (ConductorConfigs.idcounter++).toString());

    this.conductor = widget.conductor ?? ConductorConfigs.globalConductor;
    this.conductor.addListener(
        this.id,
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
    return widget.builder(context, this.conductor);
  }
}
