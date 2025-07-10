import 'package:flutter/material.dart';

/// A widget that displays a list of items with drag-and-drop capabilities.
/// 
/// This widget allows dragging items out and optionally accepting dropped items.
/// You can customize the appearance and behavior with its properties.
class CustomDragList extends StatelessWidget {
  /// Creates a [CustomDragList].
  ///
  /// The [title], [items], [enableDrag], and [enableDrop] parameters are required.
  const CustomDragList({
    super.key,
    required this.title,
    required this.items,
    required this.enableDrag,
    required this.enableDrop,
    this.hoverColor = Colors.blue,
    this.emptyPlaceholder,
    this.onItemDropped,
  });

  /// The title displayed above the list.
  final String title;

  /// The list of items to display.
  ///
  /// Each item must be a `Map<String, dynamic>` containing at least a `name` key.
  final List<Map<String, dynamic>> items;

  /// Whether dragging items is enabled.
  final bool enableDrag;

  /// Whether dropping items is enabled.
  final bool enableDrop;

  /// The color shown when an item is hovering over the drop target.
  final Color hoverColor;

  /// A widget displayed when the list is empty.
  final Widget? emptyPlaceholder;

  /// Callback invoked when an item is dropped onto the list.
  ///
  /// Receives the dropped item as a parameter.
  final void Function(Map<String, dynamic> data)? onItemDropped;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              if (!enableDrop) return false;
              return true;
            },
            onAcceptWithDetails: (details) {
              if (enableDrop && onItemDropped != null) {
                onItemDropped!(details.data);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty && enableDrop
                      ? Colors.blue.shade200
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: items.isEmpty
                    ? (emptyPlaceholder ?? const Center(child: Text("No items")))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isLocked = item["locked"] == true;

                          if (enableDrag && !isLocked) {
                            return Draggable<Map<String, dynamic>>(
                              data: item,
                              feedback: Material(
                                elevation: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: isLocked
                                      ? Colors.grey
                                      : Colors.green.shade700,
                                  child: Text(
                                    item["name"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: ListTile(title: Text(item["name"])),
                              ),
                              child: ListTile(
                                title: Text(item["name"]),
                                hoverColor: Colors.blue.shade100,
                                onTap: () {},
                              ),
                            );
                          } else {
                            return ListTile(
                              title: Text(
                                item["name"],
                                style: TextStyle(
                                  color: isLocked ? Colors.grey : Colors.black,
                                ),
                              ),
                            );
                          }
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}