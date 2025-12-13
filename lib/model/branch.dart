class Branch {   // 대리점
  int bid;       // 대리점 번호 (PK)
  double blat;   // 위도
  double blng;   // 경도
  String bname;  // 대리점 이름

  Branch({
    required this.bid,
    required this.blat,
    required this.blng,
    required this.bname,
  });

  factory Branch.fromMap(Map<String, dynamic> res) => Branch(
        bid: (res['bid'] as int?) ?? 0,
        blat: (res['blat'] as num?)?.toDouble() ?? 0.0,
        blng: (res['blng'] as num?)?.toDouble() ?? 0.0,
        bname: (res['bname'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'bid': bid,
        'blat': blat,
        'blng': blng,
        'bname': bname,
      };
}
