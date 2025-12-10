class Branch {      // 대리점

  int bid;          // 대리점 번호 (PK)
  double blat;      // 위도
  double blng;      // 경도
  String bname;     // 대리점 이름

  Branch(
    {
      required this.bid,
      required this.blat,
      required this.blng,
      required this.bname,
    }
  );

  Branch.fromMap(Map<String, dynamic> res)
  : bid = res['bid'],
    blat = res['blat'],
    blng = res['blng'],
    bname = res['bname'];

}