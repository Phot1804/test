import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/expense.dart';
import '../../repository/database_repository.dart';

// หน้าเพิ่มข้อมูล (Add Form)
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final DatabaseRepository _dbRepo = DatabaseRepository();

  String _selectedType = 'รายจ่าย';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ฟังก์ชันบันทึกข้อมูลและย้อนกลับไปหน้าหลัก
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final newExpense = Expense(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      // บันทึกลง SQLite
      await _dbRepo.insertExpense(newExpense);

      if (mounted) {
        // ปิดหน้าฟอร์ม ย้อนกลับไปหน้าหลัก พร้อมส่งค่า true บอกว่าบันทึกสำเร็จ
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มรายการใหม่', style: GoogleFonts.kanit()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        // เพิ่มปุ่มกากบาทมุมซ้ายบนสำหรับกดปิด/ย้อนกลับ
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextFormField ชื่อรายการ
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.kanit(),
                decoration: InputDecoration(
                  labelText: 'ชื่อรายการ',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อรายการ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TextFormField จำนวนเงิน
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.kanit(),
                decoration: InputDecoration(
                  labelText: 'จำนวนเงิน',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกจำนวนเงิน';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // DropdownButtonFormField เลือกประเภท
              DropdownButtonFormField<String>(
                value: _selectedType,
                style: GoogleFonts.kanit(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'ประเภท',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'รายรับ', child: Text('รายรับ')),
                  DropdownMenuItem(value: 'รายจ่าย', child: Text('รายจ่าย')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // ปุ่มกดบันทึก
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'บันทึกข้อมูล',
                  style: GoogleFonts.kanit(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}