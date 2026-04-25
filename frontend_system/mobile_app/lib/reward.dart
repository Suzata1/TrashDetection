// import 'package:flutter/material.dart';

// class RewardPage extends StatelessWidget {
//   const RewardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: const Text('API Response'),
      
//       ),
//       body: Center(
//         child: Text('This is the reward page'),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'dashboard.dart';
// class RewardPage extends StatefulWidget {
//   const RewardPage({super.key});

//   @override
//   State<RewardPage> createState() => _RewardPageState();
// }

// class _RewardPageState extends State<RewardPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   bool _isVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
//     _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     // Start animations after a tiny delay
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (mounted) {
//         setState(() => _isVisible = true);
//         _controller.forward();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//      appBar: AppBar(
//   leading: IconButton(
//     icon: const Icon(Icons.arrow_back, color: Colors.green),
//     onPressed: () {
//       Navigator.pop(context);
//     },
//   ),
//   title: const Text(
//     'API Response',
//     style: TextStyle(color: Colors.green),
//   ),
//   backgroundColor: Colors.white,
//   elevation: 0,
// ),
//       body: Column(
//         children: [
//           const SizedBox(height: 40),
          
//           // 1. Animated Checkmark
//           ScaleTransition(
//             scale: _scaleAnimation,
//             child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
//           ),
          
//           const SizedBox(height: 20),
//           const Text(
//             'Recycle Item saved successfully',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 40),

//           // 2. Animated Info Card
//           SlideTransition(
//             position: _slideAnimation,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 500),
//               opacity: _isVisible ? 1.0 : 0.0,
//               child: Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Simple Pulse for the Medal
//                       TweenAnimationBuilder(
//                         tween: Tween<double>(begin: 0.8, end: 1.0),
//                         duration: const Duration(milliseconds: 800),
//                         builder: (context, double val, child) => Transform.scale(scale: val, child: child),
//                         child: const Icon(Icons.emoji_events, color: Colors.orange, size: 100),
//                       ),
//                       const SizedBox(height: 20),
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text("Material Name: bottles", style: TextStyle(color: Colors.black54)),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         "Contribution: You contributed to reduce 100-200g of CO2",
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//                const SizedBox(height: 20),
        

//           // 3. Text Button
//            TextButton(
//                  style: TextButton.styleFrom(
//                  backgroundColor: Colors.green,
//                    minimumSize: const Size(140, 50),
//                         ),
//                   onPressed: () {
//                   Navigator.push(
//                     context,
//                         MaterialPageRoute(builder: (context) => DashboardPage()),
//                         );
//                           },
//                        child: const Text(
//                        "Go to Dashboard",
//                         style: TextStyle(color: Colors.white),
//                    ),
//                     ),
//                 const SizedBox(height: 94),
//           // 4. Animated Bottom Bar
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 800),
//             height: _isVisible ? 60 : 0,
//             width: double.infinity,
//             color: Colors.green.shade700,
//             alignment: Alignment.center,
//             child: const Text(
//               "Item recycled successfully",
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  // Dummy reward data (later replace with API/Firebase)
  final List<Map<String, String>> rewards = const [
    {
      "material": "Bottles",
      "co2": "100-200g CO2 reduced",
      "date": "18 Apr 2026"
    },
    {
      "material": "Plastic Bags",
      "co2": "50-100g CO2 reduced",
      "date": "17 Apr 2026"
    },
    {
      "material": "Paper",
      "co2": "30-60g CO2 reduced",
      "date": "15 Apr 2026"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Reward History"),
        backgroundColor: Colors.green,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final item = rewards[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: Colors.orange,
                size: 40,
              ),

              title: Text(
                item["material"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                item["co2"]!,
              ),

              trailing: Text(
                item["date"]!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}