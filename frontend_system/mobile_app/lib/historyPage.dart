// import 'package:flutter/material.dart';

// class WasteItem {
//   final String userId;
//   final String name;
//   final int quantity;
//   final DateTime dateTime;
//   final int points;

//   WasteItem({
//     required this.userId,
//     required this.name,
//     required this.quantity,
//     required this.dateTime,
//     required this.points,
//   });
// }

// class HistoryPage extends StatefulWidget {
//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   String currentUserId = "user_123";

//   List<WasteItem> allItems = [];

//   TextEditingController nameController = TextEditingController();
//   TextEditingController qtyController = TextEditingController();

//   int totalPoints = 0;

//   //  Add Waste Item
//   void addWaste() {
//     if (nameController.text.isEmpty || qtyController.text.isEmpty) return;

//     int qty = int.parse(qtyController.text);

//     //  POINT RULE (you can change this)
//     int points = qty * 2;

//     WasteItem item = WasteItem(
//       userId: currentUserId,
//       name: nameController.text,
//       quantity: qty,
//       dateTime: DateTime.now(),
//       points: points,
//     );

//     setState(() {
//       allItems.add(item);
//       totalPoints += points;
//     });

//     nameController.clear();
//     qtyController.clear();
//   }

//   // Filter user history
//   List<WasteItem> getUserItems() {
//     return allItems
//         .where((e) => e.userId == currentUserId)
//         .toList()
//         .reversed
//         .toList();
//   }

//   // Build collected items list
//   Widget buildCollectedItems(List<WasteItem> items) {
//     return ListView.builder(
//       itemCount: items.length,
//       padding: EdgeInsets.all(12),
//       itemBuilder: (context, index) {
//         final item = items[index];

//         return Card(
//           margin: EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 🟢 Left Icon Section
//                 Column(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: Colors.green[100],
//                       child: Icon(Icons.recycling, color: Colors.green),
//                     ),
//                     Container(width: 2, height: 40, color: Colors.grey[300]),
//                     Icon(Icons.check_circle, color: Colors.black),
//                   ],
//                 ),

//                 SizedBox(width: 12),

//                 // 📄 Middle Content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.name,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       SizedBox(height: 4),

//                       Text("Qty: ${item.quantity} pcs"),

//                       Text(
//                         "Date: ${item.dateTime.toLocal().toString().split(' ')[0]}",
//                       ),

//                       Text(
//                         "Time: ${item.dateTime.hour.toString().padLeft(2, '0')}:${item.dateTime.minute.toString().padLeft(2, '0')}",
//                       ),
//                     ],
//                   ),
//                 ),

//                 // 🟡 Right Badge
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.green[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     "${item.quantity} pcs",
//                     style: TextStyle(
//                       color: Colors.green[800],
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userItems = getUserItems();

//     return Scaffold(
//       backgroundColor: Colors.grey[100],

//       appBar: AppBar(
//         title: Text("Waste History"),
//         backgroundColor: Colors.green,
//       ),

//       body: Column(
//         children: [
//           //  POINT CARD
//           Container(
//             margin: EdgeInsets.all(12),
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.green[100],
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.emoji_events, size: 40, color: Colors.green),
//                 SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Your Points", style: TextStyle(fontSize: 16)),
//                     Text(
//                       "$totalPoints points",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           //  INPUT AREA
        

//           //  HISTORY LIST
//          Widget buildCollectedItems(List<WasteItem> items) {
//   return ListView.builder(
//     itemCount: items.length,
//     padding: EdgeInsets.all(12),
//     itemBuilder: (context, index) {
//       final item = items[index];

//       return Card(
//         margin: EdgeInsets.only(bottom: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🟢 Left Icon Section
//               Column(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: Colors.green[100],
//                     child: Icon(
//                       Icons.recycling,
//                       color: Colors.green,
//                     ),
//                   ),
//                   Container(
//                     width: 2,
//                     height: 40,
//                     color: Colors.grey[300],
//                   ),
//                   Icon(Icons.check_circle, color: Colors.black),
//                 ],
//               ),

//               SizedBox(width: 12),

//               // 📄 Middle Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     SizedBox(height: 4),

//                     Text("Qty: ${item.quantity} pcs"),

//                     Text(
//                       "Date: ${item.dateTime.toLocal().toString().split(' ')[0]}",
//                     ),

//                     Text(
//                       "Time: ${item.dateTime.hour.toString().padLeft(2, '0')}:${item.dateTime.minute.toString().padLeft(2, '0')}",
//                     ),
//                   ],
//                 ),
//               ),

//               // 🟡 Right Badge
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.green[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   "${item.quantity} pcs",
//                   style: TextStyle(
//                     color: Colors.green[800],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class WasteItem {
  final String userId;
  final String name;
  final int quantity;
  final DateTime dateTime;
  final int points;

  WasteItem({
    required this.userId,
    required this.name,
    required this.quantity,
    required this.dateTime,
    required this.points,
  });
}

class HistoryPage extends StatefulWidget {
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String currentUserId = "user_123";

  // 🔥 This will later come from scanner / backend (Firebase, API, etc.)
  List<WasteItem> allItems = [
    WasteItem(
      userId: "user_123",
      name: "Plastic Bottle",
      quantity: 5,
      dateTime: DateTime.now().subtract(Duration(days: 1)),
      points: 10,
    ),
    WasteItem(
      userId: "user_123",
      name: "Paper Waste",
      quantity: 3,
      dateTime: DateTime.now(),
      points: 6,
    ),
  ];

  int get totalPoints {
    return allItems
        .where((e) => e.userId == currentUserId)
        .fold(0, (sum, item) => sum + item.points);
  }

  List<WasteItem> getUserItems() {
    return allItems
        .where((e) => e.userId == currentUserId)
        .toList()
        .reversed
        .toList();
  }

  Widget buildHistoryList(List<WasteItem> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.recycling, color: Colors.green),
                    ),
                    Container(width: 2, height: 40, color: Colors.grey[300]),
                    const Icon(Icons.check_circle, color: Colors.black),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Qty: ${item.quantity} pcs"),
                      Text(
                        "Date: ${item.dateTime.toLocal().toString().split(' ')[0]}",
                      ),
                      Text(
                        "Time: ${item.dateTime.hour.toString().padLeft(2, '0')}:${item.dateTime.minute.toString().padLeft(2, '0')}",
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "+${item.points} pts",
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userItems = getUserItems();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Collection History"),
        backgroundColor: Colors.green,
      ),

      body: Column(
        children: [
          // POINT CARD
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, size: 40, color: Colors.green),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Points", style: TextStyle(fontSize: 16)),
                    Text(
                      "$totalPoints points",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // HISTORY LIST
          Expanded(
            child: userItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No scanned history yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : buildHistoryList(userItems),
          ),
        ],
      ),
    );
  }
}
