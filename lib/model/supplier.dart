class Supplier { // 제조사
  int sid;       // 제조사 번호 (PK)
  String sname;  // 제조사 이름

  Supplier({
    required this.sid,
    required this.sname,
  });

  factory Supplier.fromMap(Map<String, dynamic> res) => Supplier(
        sid: (res['sid'] as int?) ?? 0,
        sname: (res['sname'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'sid': sid,
        'sname': sname,
      };
}