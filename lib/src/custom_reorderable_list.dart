import 'package:flutter/material.dart';

class CustomReorderableList extends StatefulWidget {
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

  final String title;
  final List<Map<String, dynamic>> items;
  final bool enableDrag;
  final bool enableDrop;
  final Color hoverColor;
  final Widget? emptyPlaceholder;
  final void Function(Map<String, dynamic> data, int insertIndex)? onItemDropped;

  @override
  State<CustomReorderableList> createState() => _CustomReorderableListState();
}

class _CustomReorderableListState extends State<CustomReorderableList> {
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
                final alreadyExists = widget.items.any((e) => e['id'] == details.data['id']);
                
                if (!alreadyExists) {
                  widget.onItemDropped!(details.data, insertIndex.clamp(0, widget.items.length));
                }
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty && widget.enableDrop
                    ? widget.hoverColor.withOpacity(0.2)
                    : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey.shade300
                  ),
                  borderRadius: BorderRadius.circular(8.0)
                ),
                child: widget.items.isEmpty
                    ? (widget.emptyPlaceholder ?? const Center(child: Text("No items")))
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
                                  border: _defineBorderPosition(isHovered: isHovered)
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
                                        style: const TextStyle(color: Colors.white)
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