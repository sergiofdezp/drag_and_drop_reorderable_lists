import 'package:flutter/material.dart';

/// A widget that displays a list of items with drag-and-drop reordering support.
/// 
/// This widget allows both adding items by dropping and reordering items inside the list.
class CustomReorderableList extends StatefulWidget {
  /// Creates a [CustomReorderableList].
  ///
  /// The [title], [items], [enableDrag], and [enableDrop] parameters are required.
  const CustomReorderableList({
    super.key,
    required this.title,
    required this.items,
    required this.enableDrag,
    required this.enableDrop,
    this.hoverColor = Colors.green,
    this.emptyPlaceholder,
    this.onItemDropped,
  });

  /// The title displayed above the list.
  final String title;

  /// The list of items to display.
  ///
  /// Each item must be a `Map<String, dynamic>` containing at least a `name` key.
  final List<Map<String, dynamic>> items;

  /// Whether dragging items within the list is enabled.
  final bool enableDrag;

  /// Whether dropping items onto the list is enabled.
  final bool enableDrop;

  /// The color used for the drag feedback widget.
  final Color hoverColor;

  /// A widget displayed when the list has no items.
  final Widget? emptyPlaceholder;

  /// Callback invoked when an item is dropped.
  ///
  /// Receives the dropped item and the insert index.
  final void Function(Map<String, dynamic> data, int insertIndex)? onItemDropped;

  @override
  State<CustomReorderableList> createState() => _CustomReorderableListState();
}

/// State for [CustomReorderableList].
class _CustomReorderableListState extends State<CustomReorderableList> {
  /// The item currently hovered by the drag target.
  Map<String, dynamic>? hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              if (!widget.enableDrop) return false;
              return true;
            },
            onAcceptWithDetails: (details) {
              if (widget.enableDrop && widget.onItemDropped != null) {
                final insertIndex = widget.items.length;
                final alreadyExists = widget.items.any(
                  (e) => e['id'] == details.data['id'],
                );

                if (!alreadyExists) {
                  widget.onItemDropped!(
                    details.data,
                    insertIndex.clamp(0, widget.items.length),
                  );
                }
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty && widget.enableDrop
                      ? Colors.green.shade200
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: widget.items.isEmpty
                    ? (widget.emptyPlaceholder ??
                        const Center(child: Text("No items")))
                    : ListView.builder(
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isHovered = item == hoveredItem;

                          return DragTarget<Map<String, dynamic>>(
                            key: ValueKey(item["id"]),
                            onWillAcceptWithDetails: (details) {
                              if (!widget.enableDrop) return false;
                              setState(() {
                                hoveredItem = item;
                              });
                              return true;
                            },
                            onAcceptWithDetails: (details) {
                              if (widget.enableDrop && widget.onItemDropped != null) {
                                widget.onItemDropped!(details.data, index);
                              }
                              setState(() {
                                hoveredItem = null;
                              });
                            },
                            onLeave: (data) {
                              setState(() {
                                hoveredItem = null;
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              final child = AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.transparent,
                                  border: _defineBorderPosition(isHovered: isHovered),
                                ),
                                child: ListTile(
                                  title: Text(item["name"]),
                                  hoverColor: Colors.blue.shade100,
                                  onTap: () {},
                                ),
                              );

                              if (widget.enableDrag) {
                                return Draggable<Map<String, dynamic>>(
                                  data: item,
                                  feedback: Material(
                                    elevation: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      color: widget.hoverColor,
                                      child: Text(
                                        item["name"],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: child,
                                  ),
                                  child: child,
                                );
                              } else {
                                return child;
                              }
                            },
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Defines the border decoration based on whether the item is hovered.
  Border _defineBorderPosition({required bool isHovered}) {
    if (isHovered) {
      return const Border(
        top: BorderSide(
          color: Colors.blue,
          width: 3,
        ),
      );
    }

    return const Border();
  }
}