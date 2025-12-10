class Supplier {    // 제조사

  int sid;          // 제조사 번호 (PK)
  String sname;     // 제조사 이름

  Supplier(
    {
      required this.sid,
      required this.sname,
    }
  );

  Supplier.fromMap(Map<String, dynamic> res)
  : sid = res['sid'],
    sname = res['sname'];
}
