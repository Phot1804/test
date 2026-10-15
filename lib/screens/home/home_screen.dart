import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/expense.dart';
import '../../repository/database_repository.dart';
import '../add_expense/add_expense_screen.dart';
import 'widgets/item_expense.dart';

// หน้าหลัก (Home Screen)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseRepository _dbRepo = DatabaseRepository();
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  // ดึงข้อมูลใหม่จาก SQLite
  void _refreshExpenses() {
    setState(() {
      _expensesFuture = _dbRepo.getExpenses();
    });
  }

  // ยืนยันการลบข้อมูล
  void _confirmDelete(Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ยืนยันการลบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text(
          'คุณต้องการลบรายการ "${expense.title}" ใช่หรือไม่?',
          style: GoogleFonts.kanit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ยกเลิก', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (expense.id != null) {
                await _dbRepo.deleteExpense(expense.id!);
                _refreshExpenses();
              }
            },
            child: Text('ลบข้อมูล', style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Widget แสดงการ์ดสรุปยอดรวม (รายรับ, รายจ่าย, คงเหลือ)
  Widget _buildSummaryCard(List<Expense> expenses) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var item in expenses) {
      if (item.type == 'รายรับ') {
        totalIncome += item.amount;
      } else if (item.type == 'รายจ่าย') {
        totalExpense += item.amount;
      }
    }

    double totalBalance = totalIncome - totalExpense;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'ยอดเงินคงเหลือ',
              style: GoogleFonts.kanit(fontSize: 16, color: Colors.teal.shade900),
            ),
            const SizedBox(height: 4),
            Text(
              '${totalBalance.toStringAsFixed(2)} ฿',
              style: GoogleFonts.kanit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: totalBalance >= 0 ? Colors.teal.shade800 : Colors.red,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // สรุปรายรับ
                Column(
                  children: [
                    Text('รายรับรวม', style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(
                      '+${totalIncome.toStringAsFixed(2)} ฿',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey[400]),
                // สรุปรายจ่าย
                Column(
                  children: [
                    Text('รายจ่ายรวม', style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(
                      '-${totalExpense.toStringAsFixed(2)} ฿',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: GoogleFonts.kanit()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล', style: GoogleFonts.kanit()),
            );
          }

          final expenses = snapshot.data ?? [];

          return Column(
            children: [
              // 1. ส่วนแสดงการ์ดสรุปคำนวณยอดเงิน
              _buildSummaryCard(expenses),

              // 2. ส่วนรายการย่อย
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          'ยังไม่มีรายการ บันทึกใหม่ได้เลย!',
                          style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final item = expenses[index];
                          return ItemExpense(
                            expense: item,
                            onDelete: () => _confirmDelete(item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // สลับไปหน้าเพิ่มข้อมูล และรอผลลัพธ์ย้อนกลับมา
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );

          // ถ้ารับค่ากลับมาเป็น true สั่งรีเฟรชยอดคำนวณและรายการใหม่ทันที
          if (result == true) {
            _refreshExpenses();
          }
        },
      ),
    );
  }
}