import 'package:flutter/material.dart';




class ConductorConfigs {
  static int idcounter = 1;
}





class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}





class _DemoPageState extends State<DemoPage> {
  
  Conductor sampleConductor = Conductor();

  @override
  void initState() {
    sampleConductor.update("number", 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: ConductorBuilder(
            conductor: sampleConductor,
            builder: (c, Conductor conductor) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text((conductor.getValue("number") as int).toString()),


                  FloatingActionButton(
                    child: Text("INCREMENT"),

                    onPressed: () {
                      conductor.update("number", conductor.getValue("number")+1);
                    })
                ]
              );
            }));
  }
}















class Conductor {
  Map<int, Function()> callouts = {};
  Map<String, dynamic> _values = {};

  void update(String key, dynamic value) {
    this._values[key] = value;
    this.broadcast();
  }

  dynamic getValue(String key) => this._values[key];


  void setCallout(int id, Function() callout) {
    this.callouts[id] = callout;
  }

  void broadcast() {
    this.callouts.forEach((int id, Function() callout) => callout());
  }
}

class ConductorBuilder extends StatefulWidget {
  @override
  _ConductorBuilderState createState() => _ConductorBuilderState();

  int id = ConductorConfigs.idcounter++;
  Conductor conductor;
  Widget Function(BuildContext context, Conductor conductor) builder;

  ConductorBuilder({@required this.conductor, @required this.builder});
}

class _ConductorBuilderState extends State<ConductorBuilder> {

  @override
  void initState() {
    widget.conductor.setCallout(widget.id, () => setState((){}));
    super.initState();
  }

  @override
  void dispose() {
    widget.conductor.setCallout(widget.id, () => {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.conductor);
  }
}
