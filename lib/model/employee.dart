class Employee {    // 사원 (+근무하다)

  int? eseq;        // 사원번호 (PK, AI)
  String eemail;    // 이메일
  String epw;       // 비밀번호
  String ename;     // 이름
  String ephone;    // 전화번호
  int erank;        // 직급 (1: 사원, 2: 팀장, 3: 이사, 4: 임원)
  int erole;        // 직책 (1: 일반 직원, 2: 재고 담당, 3: 발주 담당, 4: 대리점장, 5: 시스템 관리자)
  int epower;       // 권한 (1: 발주 작성 가능, 2: 팀장급 결재 승인 가능, 3: 이사급 결재 승인 가능, 4: 본사 재고 현황 파악 가능)
  int workplace;    // 근무지 (1: 본사, 2: 대리점(이후 대리점 번호로 구분))
  int? ebid;        // 대리점 번호 (근무지가 대리점일때만 판단, null 가능)

  Employee(
    {
      this.eseq,
      required this.eemail,
      required this.epw,
      required this.ename,
      required this.ephone,
      required this.erank,
      required this.erole,
      required this.epower,
      required this.workplace,
      this.ebid,
    }
  );

  Employee.fromMap(Map<String, dynamic> res)
  : eseq = res['eseq'],
    eemail = res['eemail'],
    epw = res['epw'],
    ename = res['ename'],
    ephone = res['ephone'],
    erank = res['erank'],
    erole = res['erole'],
    epower = res['epower'],
    workplace = res['workplace'],
    ebid = res['ebid'];

}