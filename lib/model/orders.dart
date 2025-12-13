class Orders {   // 발주
  int? oseq;     // 발주번호 (PK, AI)
  int ostatus;   // 발주상태 (1: 발주 요청, 2: 결재 완료 후 제조사 확인 대기, 3: 제조사 확인(수주 완료))
  String odate;  // 발주일자
  int oamount;   // 발주수량

  Orders({
    this.oseq,
    required this.ostatus,
    required this.odate,
    required this.oamount,
  });

  factory Orders.fromMap(Map<String, dynamic> res) => Orders(
        oseq: res['oseq'] as int?,
        ostatus: (res['ostatus'] as int?) ?? 0,
        odate: (res['odate'] as String?) ?? '',
        oamount: (res['oamount'] as int?) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'oseq': oseq,
        'ostatus': ostatus,
        'odate': odate,
        'oamount': oamount,
      };
}