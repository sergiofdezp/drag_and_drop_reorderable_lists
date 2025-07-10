import 'package:drag_and_drop_reorderable_lists/drag_and_drop_reorderable_lists.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DragAndDropListsPage(),
    );
  }
}

class DragAndDropListsPage extends StatefulWidget {
  const DragAndDropListsPage({super.key});

  @override
  State<DragAndDropListsPage> createState() => _DragAndDropListsPageState();
}

class _DragAndDropListsPageState extends State<DragAndDropListsPage> {
  final List<Map<String, dynamic>> list1Items = List.generate(
    8,
    (i) => {
      "id": i + 1,
      "name": "Item ${i + 1}",
      "value1": 10 + (i % 4) * 5,
      "value2": 20 + (i % 4) * 5,
      "locked": i == 2 || i == 5,
    },
  );

  final List<Map<String, dynamic>> list2Items = [];

  bool _listContains(
      List<Map<String, dynamic>> list, Map<String, dynamic> item) {
    return list.any((e) => e['id'] == item['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomDragList(
              title: "List 1",
              items: list1Items,
              enableDrag: true,
              enableDrop: true,
              hoverColor: Colors.blue,
              onItemDropped: (data) {
                setState(() {
                  if (!_listContains(list1Items, data)) {
                    list1Items.add(data);
                    list2Items.removeWhere((e) => e['id'] == data['id']);
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: CustomReorderableList(
              title: "List 2",
              items: list2Items,
              enableDrag: true,
              enableDrop: true,
              hoverColor: Colors.blue,
              onItemDropped: (data, insertIndex) {
                setState(() {
                  list2Items.removeWhere((e) => e['id'] == data['id']);
                  list2Items.insert(insertIndex, data);
                  list1Items.removeWhere((e) => e['id'] == data['id']);
                });
              },
            ),
          ),
        ],
      ),
    ));
  }
}
