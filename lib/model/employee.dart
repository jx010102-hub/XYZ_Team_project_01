class Employee {    // 사원 (+근무)
  int? eseq;        // 사원번호 (PK, AI)
  String eemail;    // 이메일
  String epw;       // 비밀번호
  String ename;     // 이름
  String ephone;    // 전화번호
  int erank;        // 직급 (1: 사원, 2: 팀장, 3: 이사, 4: 임원)
  int erole;        // 직책 (1: 일반 직원, 2: 재고 담당, 3: 발주 담당, 4: 대리점장, 5: 시스템 관리자)
  int epower;       // 권한 (1: 발주 작성 가능, 2: 팀장급 결재 승인 가능, 3: 이사급 결재 승인 가능, 4: 본사 재고 현황 파악 가능)
  int workplace;    // 근무지 (1: 본사, 2: 대리점)
  int? ebid;        // 대리점 번호(Branch.bid) - workplace가 대리점일 때만

  Employee({
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
  });

  factory Employee.fromMap(Map<String, dynamic> res) => Employee(
        eseq: res['eseq'] as int?,
        eemail: (res['eemail'] as String?) ?? '',
        epw: (res['epw'] as String?) ?? '',
        ename: (res['ename'] as String?) ?? '',
        ephone: (res['ephone'] as String?) ?? '',
        erank: (res['erank'] as int?) ?? 0,
        erole: (res['erole'] as int?) ?? 0,
        epower: (res['epower'] as int?) ?? 0,
        workplace: (res['workplace'] as int?) ?? 0,
        ebid: res['ebid'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'eseq': eseq,
        'eemail': eemail,
        'epw': epw,
        'ename': ename,
        'ephone': ephone,
        'erank': erank,
        'erole': erole,
        'epower': epower,
        'workplace': workplace,
        'ebid': ebid,
      };
}