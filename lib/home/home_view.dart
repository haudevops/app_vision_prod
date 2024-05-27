import 'dart:convert';

import 'package:app_vision_prod/detection_item/detection_item_view.dart';
import 'package:app_vision_prod/model/product_model.dart';
import 'package:app_vision_prod/scan_barcode/scan_barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? dataString;
  ProductModel? productModel;
  final searchController = TextEditingController();
  final focusNodeInput = FocusNode();

  @override
  void initState() {
    loadJson();
    super.initState();
  }

  loadJson() async {
    final data = await rootBundle.loadString('assets/js/data.json');
    final jsonData = json.decode(data);
    setState(() {
      productModel = ProductModel.fromJson(jsonData);
    });
    print('productModel: ${productModel?.toJson()}');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Danh sách sản phẩm',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                loadJson();
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DetectionItemView()))
                    .then((value) {
                  if(value != null) {
                    setState(() {
                      searchController.text = value;
                      productModel?.data?.removeWhere((e) => e.productName?.toLowerCase() != searchController.text.toLowerCase());
                    });
                  }

                });
              },
              onDoubleTap: () {},
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.camera_alt,
                  size: 25,
                  color: Colors.black,
                ),
              ))
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(5),
        child: Column(
          children: [
            scanBarcodeWidget(),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: productModel?.data?.length,
                  itemBuilder: (context, index) {
                    return listItemProduct(data: productModel?.data?[index]);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget scanBarcodeWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            focusNode: focusNodeInput,
            controller: searchController,
            textCapitalization: TextCapitalization.words,
            onFieldSubmitted: (value) {
              setState(() {
                for (final i in productModel!.data!) {
                  if (value == i.productName?.toLowerCase() || value == i.sku) {
                    productModel?.data?.clear();
                    productModel?.data?.add(i);
                  }
                }
              });
            },
            onChanged: (value) {
              if(value.isEmpty) {
                loadJson();
              }
            },
            style: const TextStyle(color: Colors.black, fontSize: 15),
            decoration: InputDecoration(
                suffixIcon: InkWell(
                    onTap: () {
                      searchController.clear();
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScanBarcodePage()))
                          .then((value) {
                            print('value: $value');
                            // loadJson();
                        if (value != null) {
                          setState(() {
                            productModel?.data?.removeWhere((e) => e.barcode != value);
                            searchController.text = value;
                          });
                        }
                      });
                    },
                    onDoubleTap: () {},
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.black,
                    )),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 10.0),
                isDense: false,
                filled: true,
                fillColor: Colors.white,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                hintText: 'Nhập/Quét sản phẩm',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFF3C34D), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.white24, width: 1),
                ))));
  }

  Widget listItemProduct({ProductItem? data}) {
    return Card(
      color: Colors.white,
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        minVerticalPadding: 10,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.local_convenience_store_rounded,
            size: 20,
          ),
        ),
        title: Text(
          data?.productName ?? '',
          style: const TextStyle(fontSize: 18),
        ),
        subtitle: Text(
          '${data?.sku} - ${data?.barcode}' ?? '',
          style: const TextStyle(fontSize: 16),
        ),

        // trailing: Text(
        //   DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now()),
        //   style:
        //       TextStyle(fontSize: ScreenUtil.getInstance().getAdapterSize(14)),
        // ),
        // trailing: const Icon(Icons.more_vert),
        isThreeLine: true,
      ),
    );
  }
}
