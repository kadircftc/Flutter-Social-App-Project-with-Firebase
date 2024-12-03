// ignore_for_file: file_names

import 'package:flutter/material.dart';

class NoDeleteFuture extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  const NoDeleteFuture(
      {super.key, required this.future, required this.builder});

  @override
  State<NoDeleteFuture> createState() => _NoDeleteFutureState();
}

class _NoDeleteFutureState extends State<NoDeleteFuture>
    with AutomaticKeepAliveClientMixin<NoDeleteFuture> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(future: widget.future, builder: widget.builder);
  }

  @override
  bool get wantKeepAlive => true;
}
