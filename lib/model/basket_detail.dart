// lib/model/basket_detail.dart
import 'package:xyz_project_01/model/basket.dart';
import 'package:xyz_project_01/model/goods.dart';

class BasketDetail {
  final Basket basket;
  final Goods? goods; // variant
  BasketDetail({required this.basket, required this.goods});

  BasketDetail copyWith({
    Basket? basket,
    Goods? goods,
  }) {
    return BasketDetail(
      basket: basket ?? this.basket,
      goods: goods ?? this.goods,
    );
  }
}
