import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // แพ็กเกจ intl ตามข้อกำหนดโจทย์
import '../../../models/expense.dart';

// Widget แสดงรายการย่อยแต่ละรายการ
class ItemExpense extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ItemExpense({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Logic บังคับ: รายรับ = สีเขียว (+) / รายจ่าย = สีแดง (-)
    final isIncome = expense.type == 'รายรับ';
    final color = isIncome ? Colors.green : Colors.red;

    // Data Formatting: ใช้วิดเจ็ต Text แสดงวันที่บันทึก (แปลงด้วย intl รูปแบบ dd MMM yyyy)
    final formattedDate = DateFormat('dd MMM yyyy').format(expense.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 6)), // แถบสีแยกประเภท
          borderRadius: BorderRadius.circular(10),
        ),
        // Layout: จัดวางด้วย Row, Column, Expanded ให้สวยงาม ไม่ล้นจอ
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // แสดงข้อความวันที่ด้วยฟอร์แมต intl
                  Text(
                    formattedDate,
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Container แสดงข้อความราคา ปรับเป็นสีเขียว/แดง ตามเงื่อนไข
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isIncome ? '+' : '-'}${expense.amount.toStringAsFixed(2)} ฿',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ปุ่ม Icon ถังขยะ สำหรับดักจับการกดเพื่อลบข้อมูล
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}