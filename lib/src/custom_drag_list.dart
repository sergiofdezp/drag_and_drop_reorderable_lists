import 'package:flutter/material.dart';

class CustomDragList extends StatelessWidget {
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

  final String title;
  final List<Map<String, dynamic>> items;
  final bool enableDrag;
  final bool enableDrop;
  final Color hoverColor;
  final Widget? emptyPlaceholder;
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
                      ? hoverColor.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8.0)
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
                                  color: isLocked ? Colors.grey : Colors.green.shade700,
                                  child: Text(
                                    item["name"],
                                    style: const TextStyle(color: Colors.white)
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
                                  color: isLocked ? Colors.grey : Colors.black
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