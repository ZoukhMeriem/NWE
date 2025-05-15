import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [Icons.home, Icons.person, Icons.chat];
    final List<String> labels = ["Accueil", "Compte", "Chat"];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 🔹 Barre de fond
        Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFA4C6A8),   // vert doux
                Color(0xFFF4D9DE),   // rose clair
                Color(0xFFDDD7E8),   // lavande
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return GestureDetector(
                onTap: () => onItemTapped(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      duration: Duration(milliseconds: 300),
                      scale: selectedIndex == index ? 1.2 : 1.0,
                      child: Icon(
                        icons[index],
                        color: selectedIndex == index
                            ? Colors.transparent // caché car recouvert par la bulle
                            : const Color(0xFF1E1E1E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.transparent
                            : Color(0xFF1E1E1E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // 🔸 Cercle rose mobile
        Positioned(
          bottom: 10,
          left: MediaQuery.of(context).size.width *
              (selectedIndex == 0 ? 0.13 : selectedIndex == 1 ? 0.45 : 0.77),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Color(0x151A5EFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icons[selectedIndex],
              color:  Color(0xFF0C3243),
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
