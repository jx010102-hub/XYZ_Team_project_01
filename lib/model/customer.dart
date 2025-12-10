class Customer {    // 고객

  int? cseq;        // 사용자번호 (PK, AI)
  String cemail;    // 이메일
  String cpw;       // 비밀번호
  String cphone;    // 전화번호
  String cname;     // 이름
  String caddress;  // 주소

  Customer(
    {
      this.cseq,
      required this.cemail,
      required this.cpw,
      required this.cphone,
      required this.cname,
      required this.caddress,
    }
  );

  Customer.fromMap(Map<String, dynamic> res)
  : cseq = res['cseq'],
    cemail = res['cemail'],
    cpw = res['cpw'],
    cphone = res['cphone'],
    cname = res['cname'],
    caddress = res['caddress'];

}