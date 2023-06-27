import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/soro.jpg"),
          ),
        ],
      ),
    );
  }
}
