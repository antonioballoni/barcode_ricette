import 'package:flutter/material.dart';

class InheretedData<T extends ChangeNotifier> extends InheritedWidget {
  final DataStoreState<T> dataStoreState;

  const InheretedData({
    Key? key,
    required this.dataStoreState,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheretedData<T> oldWidget) => true;
}

class DataStore<T extends ChangeNotifier> extends StatefulWidget {
  const DataStore({
    super.key,
    required this.data,
    required this.child,
  });

  final T data;
  final Widget child;

  @override
  State<DataStore<T>> createState() => DataStoreState();

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final InheretedData scope =
        context.dependOnInheritedWidgetOfExactType<InheretedData<T>>()!;
    return scope.dataStoreState.data as T;
  }
}

class DataStoreState<T extends ChangeNotifier> extends State<DataStore<T>> {
  late final T data;

  @override
  void initState() {
    super.initState();
    this.data = widget.data;
    data.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheretedData<T>(
      dataStoreState: this,
      child: widget.child,
    );
  }
}
