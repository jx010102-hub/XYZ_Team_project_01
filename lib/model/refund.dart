// lib/model/refund.dart

class Refund {      // 반품

  int? rseq;        // 반품번호 (AI)
  String rdate;     // 반품일자
  String rreason;   // 반품사유
  int rstatus;      // 반품상태 (1: 반품 요청, 승인 대기, 2: 승인 완료, 반품 대기, 3: 반품 완료)
  int rpseq;        // 주문번호 (Purchase에 등록된 주문번호)

  Refund(
    {
      this.rseq,
      required this.rdate,
      required this.rreason,
      required this.rstatus,
      required this.rpseq,
    }
  );

  Refund.fromMap(Map<String, dynamic> res)
  : rseq = res['rseq'],
    rdate = res['rdate'],
    rreason = res['rreason'],
    rstatus = res['rstatus'],
    rpseq = res['rpseq'];
    
    Map<String, dynamic> toMap() {
        return {
            'rseq': rseq,
            'rdate': rdate,
            'rreason': rreason,
            'rstatus': rstatus,
            'rpseq': rpseq,
        };
    }
}