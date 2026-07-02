import 'package:flutter/material.dart';

/// An IndexedStack that builds its children lazily.
///
/// It only instantiates children when their index is selected for the first time.
/// Subsequent visits to the same index reuse the already-initialized widget.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List<bool>.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index < _activated.length && !_activated[widget.index]) {
      setState(() {
        _activated[widget.index] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List<Widget>.generate(
        widget.children.length,
        (i) {
          return _activated[i] ? widget.children[i] : const SizedBox.shrink();
        },
      ),
    );
  }
}
