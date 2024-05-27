class ProductModel {
  ProductModel({this.data});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        data: json['data'] == null
            ? null
            : (json['data'] as List)
                .map((e) => ProductItem.fromJson(e))
                .toList());
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }

  List<ProductItem>? data;
}

class ProductItem {
  ProductItem({this.productName, this.sku, this.qty, this.barcode});

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
        productName: json['productName'],
        qty: json['qty'],
        sku: json['sku'],
        barcode: json['barcode']);
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'qty': qty,
      'sku': sku,
      'barcode': barcode
    };
  }

  String? productName;
  String? qty;
  String? sku;
  String? barcode;
}
