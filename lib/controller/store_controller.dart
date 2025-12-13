import 'package:get/get.dart';

class StoreController extends GetxController {
  // 선택된 매장 정보를 Map으로 저장
  final Rxn<Map<String, dynamic>> selectedStore = Rxn<Map<String, dynamic>>();

  void setStore(Map<String, dynamic> store) {
    selectedStore.value = store;
  }

  void clearStore() {
    selectedStore.value = null;
  }
}