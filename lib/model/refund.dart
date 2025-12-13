class Refund {    // 반품
  int? rseq;      // 반품번호 (PK, AI)
  String rdate;   // 반품일자
  String rreason; // 반품사유
  int rstatus;    // 반품상태 (1: 반품 요청(승인 대기), 2: 승인 완료(반품 대기), 3: 반품 완료)
  int rpseq;      // 주문번호(Purchase.pseq)

  Refund({
    this.rseq,
    required this.rdate,
    required this.rreason,
    required this.rstatus,
    required this.rpseq,
  });

  factory Refund.fromMap(Map<String, dynamic> res) => Refund(
        rseq: res['rseq'] as int?,
        rdate: (res['rdate'] as String?) ?? '',
        rreason: (res['rreason'] as String?) ?? '',
        rstatus: (res['rstatus'] as int?) ?? 0,
        rpseq: (res['rpseq'] as int?) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'rseq': rseq,
        'rdate': rdate,
        'rreason': rreason,
        'rstatus': rstatus,
        'rpseq': rpseq,
      };
}