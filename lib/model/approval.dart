class Approval {    // 결재

  int? aseq;        // 결재번호 (AI)
  int astatus;      // 결재상태 (1: 발주 건 결재 요청, 2: 팀장까지 승인, 3: 이사까지 승인 완료, 발주 진행)
  String adate;     // 결재일자
  int aoseq;        // 발주번호 (어떤 발주에 대한 결재인지 알아야 함)

  Approval(
    {
      this.aseq,
      required this.astatus,
      required this.adate,
      required this.aoseq,
    }
  );

  Approval.fromMap(Map<String, dynamic> res)
  : aseq = res['aseq'],
    astatus = res['astatus'],
    adate = res['adate'],
    aoseq = res['aoseq'];

}