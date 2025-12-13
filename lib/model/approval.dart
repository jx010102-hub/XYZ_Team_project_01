class Approval { // 결재
  int? aseq;     // 결재번호 (PK, AI)
  int astatus;   // 결재상태 (1: 발주 건 결재 요청, 2: 팀장 승인 완료, 3: 이사 승인 완료(발주 진행 가능))
  String adate;  // 결재일자
  int aoseq;     // 발주번호(Orders.oseq) - 어떤 발주에 대한 결재인지

  Approval({
    this.aseq,
    required this.astatus,
    required this.adate,
    required this.aoseq,
  });

  factory Approval.fromMap(Map<String, dynamic> res) => Approval(
        aseq: res['aseq'] as int?,
        astatus: (res['astatus'] as int?) ?? 0,
        adate: (res['adate'] as String?) ?? '',
        aoseq: (res['aoseq'] as int?) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'aseq': aseq,
        'astatus': astatus,
        'adate': adate,
        'aoseq': aoseq,
      };
}