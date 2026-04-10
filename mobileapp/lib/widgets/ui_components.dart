import 'package:flutter/material.dart';

Widget buildCustomTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
  int maxLines = 1,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.0 : 0),
          child: Icon(icon, color: Colors.grey[400]),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    ),
  );
}

Widget buildActionButton({
  required String text,
  required VoidCallback? onPressed,
  required bool isLoading,
  required Color color,
}) {
  return Container(
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: color,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}

Widget buildLogo() {
  return Column(
    children: [
      Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_circle_outline,
          size: 60,
          color: Color(0xFF6B72FF),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'taskomat',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6A6A6A),
        ),
      ),
    ],
  );
}
