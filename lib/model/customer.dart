class Customer {    // 고객
  int? cseq;        // 사용자번호 (PK, AI)
  String cemail;    // 이메일 (로그인 식별자로 쓰면 UNIQUE 권장)
  String cpw;       // 비밀번호
  String cphone;    // 전화번호
  String cname;     // 이름
  String caddress;  // 주소

  Customer({
    this.cseq,
    required this.cemail,
    required this.cpw,
    required this.cphone,
    required this.cname,
    required this.caddress,
  });

  factory Customer.fromMap(Map<String, dynamic> res) => Customer(
        cseq: res['cseq'] as int?,
        cemail: (res['cemail'] as String?) ?? '',
        cpw: (res['cpw'] as String?) ?? '',
        cphone: (res['cphone'] as String?) ?? '',
        cname: (res['cname'] as String?) ?? '',
        caddress: (res['caddress'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'cseq': cseq,
        'cemail': cemail,
        'cpw': cpw,
        'cphone': cphone,
        'cname': cname,
        'caddress': caddress,
      };
}