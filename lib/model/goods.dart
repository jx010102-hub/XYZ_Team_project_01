import 'dart:typed_data';

class Goods {         // 신발 (상품)

  int? gseq;          // 제품 번호 (PK, AI)
  int gsumamount;     // 총 재고량
  String gname;       // 제품명
  String gengname;    // 제품명 (영문)
  String gsize;       // 사이즈
  String gcolor;      // 색상
  String gcategory;   // 카테고리
  Uint8List? mainimage;// main 이미지
  Uint8List? topimage; // top 이미지
  Uint8List? backimage;// back 이미지
  Uint8List? sideimage;// side 이미지

  Goods(
    {
      this.gseq,
      required this.gsumamount,
      required this.gname,
      required this.gengname,
      required this.gsize,
      required this.gcolor,
      required this.gcategory,
      this.mainimage,
      this.topimage,
      this.backimage,
      this.sideimage,
    }
  );

  Goods.fromMap(Map<String, dynamic> res)
    : gseq = res['gseq'] as int?,
      gsumamount = res['gsumamount'] as int,
      gname = res['gname'] as String,
      gengname = res['gengname'] as String,
      gsize = res['gsize'] as String,
      gcolor = res['gcolor'] as String,
      gcategory = res['gcategory'] as String,
      mainimage = res['mainimage'] as Uint8List?,
      topimage = res['topimage'] as Uint8List?,
      backimage = res['backimage'] as Uint8List?,
      sideimage = res['sideimage'] as Uint8List?;
}