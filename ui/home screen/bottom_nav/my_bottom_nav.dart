// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../utils/constants/app_colors.dart';
// import 'provider/bottom_nav_provider.dart';
//
// class MyBottomNavigation extends StatelessWidget {
//   const MyBottomNavigation({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<BottomNavigationProvider, bool>(
//       selector: (_, provider) => provider.isLoading,
//       builder: (context, isLoading, child) {
//         if (isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return Consumer<BottomNavigationProvider>(
//           builder: (context, provider, child) {
//             final List<BottomNavigationBarItem> navItems = provider.categories.isNotEmpty
//                 ? provider.categories.map((category) {
//               return BottomNavigationBarItem(
//                 icon: const Icon(Icons.category),
//                 label: category.name,
//               );
//             }).toList()
//                 : [
//               const BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: "Home",
//               ),
//               const BottomNavigationBarItem(
//                 icon: Icon(Icons.category),
//                 label: "Categories",
//               ),
//             ];
//
//             return BottomNavigationBar(
//               currentIndex: provider.currentIndex,
//               onTap: provider.updateIndex,
//               selectedItemColor: MyAppColors.lightRedColor,
//               unselectedItemColor: MyAppColors.greyColor,
//               backgroundColor: MyAppColors.whiteColor,
//               selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//               unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//               items: navItems,
//             );
//           },
//         );
//       },
//     );
//   }
// }
