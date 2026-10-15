// Model สำหรับโครงสร้างข้อมูล Expense ตรงตามข้อกำหนดโจทย์
class Expense {
  final int? id; // ฟิลด์ id สำหรับอ้างอิงใน SQLite (เป็น null ได้หากยังไม่บันทึก)
  final String title; // ฟิลด์ title (String) เก็บชื่อรายการ
  final double amount; // ฟิลด์ amount (double) เก็บจำนวนเงิน
  final String type; // ฟิลด์ type (String) เก็บประเภท ('รายรับ' หรือ 'รายจ่าย')
  final DateTime createdAt; // ฟิลด์ createdAt (DateTime) เก็บวันเวลาที่บันทึก

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  // ฟังก์ชันแปลงข้อมูลจาก Object ไปเป็น Map<String, dynamic> เพื่อบันทึกลง SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'createdAt': createdAt.toIso8601String(), // แปลง DateTime เป็นข้อความ ISO8601
    };
  }

  // Factory Constructor แปลงข้อมูล Map ที่ดึงมาจาก SQLite กลับมาเป็น Object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(), // แปลงตัวเลขเป็น double
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']), // แปลงข้อความ ISO8601 กลับเป็น DateTime
    );
  }
}