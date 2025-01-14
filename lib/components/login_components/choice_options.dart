import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChoiceOptions extends StatefulWidget {
  final String role;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const ChoiceOptions({
    super.key,
    required this.icon,
    required this.role,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<ChoiceOptions> createState() => _ChoiceOptionsState();
}

class _ChoiceOptionsState extends State<ChoiceOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: widget.isSelected
              ? Colors.white
              : Color.fromRGBO(240, 94, 94, 1),
          backgroundColor:
              widget.isSelected ? Color.fromRGBO(240, 94, 94, 1) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: Color.fromRGBO(240, 94, 94, 1), // Border color
            width: 2,
          ),
        ),
        onPressed: widget.onSelected,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon), 
            SizedBox(width: 4),
            Text(
              widget.role,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
