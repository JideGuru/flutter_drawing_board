enum ToolType {
  pencil,
  marker,
  stamp,
  spray,
  fill,
  line,
  eraser,
  ruler;

  @override
  String toString() {
    return toString().split('.').last;
  }
}
