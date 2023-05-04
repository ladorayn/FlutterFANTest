// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutterfantest/main.dart';
//
// import '../utils/user_item_list.dart';
//
// class HomeScreen extends StatefulWidget {
//   HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   // Get the FirebaseAuth instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   var usersStream = FirebaseFirestore.instance.collection('users').snapshots();
//   var currentFilter = 'All'; // default filter value
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   onPressed: () => signOut(context),
//                   icon: Icon(Icons.logout),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "Registered Users",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 28,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Text(
//                     "Filter",
//                     style: TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor:
//                           currentFilter == 'All' ? Colors.blue : Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         currentFilter = 'All';
//                       });
//                     },
//                     child: Text(
//                       "All",
//                       style: TextStyle(
//                           color: currentFilter == 'All'
//                               ? Colors.white
//                               : Colors.black),
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: currentFilter == 'Verified'
//                           ? Colors.blue
//                           : Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         currentFilter = 'Verified';
//                         print('Current filter: $currentFilter');
//                       });
//                     },
//                     child: Text(
//                       "Verified",
//                       style: TextStyle(
//                           color: currentFilter == 'Verified'
//                               ? Colors.white
//                               : Colors.black),
//                     ),
//                   ),
//                   SizedBox(width: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: currentFilter == 'Not Verified'
//                           ? Colors.blue
//                           : Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         currentFilter = 'Not Verified';
//                       });
//                     },
//                     child: Text(
//                       "Not Verified",
//                       style: TextStyle(
//                           color: currentFilter == 'Not Verified'
//                               ? Colors.white
//                               : Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: usersStream,
//                 builder: (BuildContext context,
//                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//
//                   List<QueryDocumentSnapshot>? users = snapshot.data?.docs;
//
//                   if (currentFilter == 'Verified') {
//                     users = users
//                         ?.where((user) => (user.data()
//                             as Map<String, dynamic>)['isEmailVerified'])
//                         .toList();
//                   } else if (currentFilter == 'Not Verified') {
//                     users = users
//                         ?.where((user) => !(user.data()
//                             as Map<String, dynamic>)['isEmailVerified'])
//                         .toList();
//                   }
//
//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: users?.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       var user = users?[index];
//                       Map<String, dynamic> mUser =
//                           user?.data() as Map<String, dynamic>;
//                       return UserListItem(
//                           name: mUser['name'],
//                           email: mUser['email'],
//                           isVerified: mUser['isEmailVerified']);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void signOut(context) async {
//     await _auth.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => MyApp()),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfantest/main.dart';
import '../utils/user_item_list.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get the FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  var currentFilter = 'All'; // default filter value

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var padding = screenWidth * 0.05;
    var fontSize = screenWidth * 0.07;
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => signOut(context),
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                "Registered Users",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Filter",
                    style: TextStyle(fontSize: 20),
                  ),
                  filterButton("All"),
                  filterButton("Verified"),
                  filterButton("Not Verified"),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: usersStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<QueryDocumentSnapshot>? users = snapshot.data?.docs;

                  if (currentFilter == 'Verified') {
                    users = users
                        ?.where((user) => (user.data()
                            as Map<String, dynamic>)['isEmailVerified'])
                        .toList();
                  } else if (currentFilter == 'Not Verified') {
                    users = users
                        ?.where((user) => !(user.data()
                            as Map<String, dynamic>)['isEmailVerified'])
                        .toList();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(padding),
                    itemCount: users?.length,
                    itemBuilder: (BuildContext context, int index) {
                      var user = users?[index];
                      Map<String, dynamic> mUser =
                          user?.data() as Map<String, dynamic>;
                      return UserListItem(
                          name: mUser['name'],
                          email: mUser['email'],
                          isVerified: mUser['isEmailVerified']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(String text) {
    var isSelected = currentFilter == text;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentFilter = text;
        });
      },
      style: ButtonStyle(
        backgroundColor: isSelected
            ? MaterialStateProperty.all<Color>(Colors.blue)
            : MaterialStateProperty.all<Color>(Colors.grey),
      ),
      child: Text(text),
    );
  }

  void signOut(context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }
}
