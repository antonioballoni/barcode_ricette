import 'package:flutter/material.dart';

class InheretedData<T> extends InheritedWidget {
  const InheretedData({
    Key? key,
    required this.dataStoreState,
    required Widget child,
  }) : super(key: key, child: child);

  final DataStoreState<T> dataStoreState;

  @override
  bool updateShouldNotify(InheretedData<T> oldWidget) => true;
}

class DataStore<T> extends StatefulWidget {
  const DataStore({
    super.key,
    required this.model,
    required this.child,
  });

  final T model;
  final Widget child;

  @override
  State<DataStore<T>> createState() => DataStoreState();

  static T of<T>(BuildContext context) {
    final InheretedData scope =
        context.dependOnInheritedWidgetOfExactType<InheretedData<T>>()!;
    return scope.dataStoreState.model as T;
  }

  static void updatedOf<T>(BuildContext context) {
    final InheretedData scope =
        context.dependOnInheritedWidgetOfExactType<InheretedData<T>>()!;
    scope.dataStoreState.updated();
  }
}

class DataStoreState<T> extends State<DataStore<T>> {
  late final T model;

  @override
  void initState() {
    super.initState();
    this.model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return InheretedData<T>(
      dataStoreState: this,
      child: widget.child,
    );
  }

  void updated() {
    setState(() {
      // force rebuild
    });
  }
}
