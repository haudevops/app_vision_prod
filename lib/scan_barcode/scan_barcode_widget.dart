

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage>
    with SingleTickerProviderStateMixin {

  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void onDestroy() {
    controller?.dispose();
  }

  Widget _buildQrView(BuildContext buildContext) {
    var scanArea = (MediaQuery.of(buildContext).size.width < 500 ||
        MediaQuery.of(buildContext).size.height < 500)
        ? 250.0 : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlayMargin: EdgeInsets.only(bottom: 100),
      overlay: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(buildContext, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(scanData.code!.isNotEmpty){
        controller.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  void _onPermissionSet(
      BuildContext buildContext, QRViewController ctrl, bool p) async {
    final cameraStatus = await Permission.camera.status;

    if (cameraStatus.isGranted) {
      await ctrl.resumeCamera();
    } else {
      final cameraRequest = await Permission.camera.request();
      if (cameraRequest.isGranted) {
        await ctrl.resumeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.,
      body: Builder(
        builder: (buildContext) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.red,
            child: Stack(
              children: [
                _buildQrView(buildContext),
                Positioned(
                  top: 10,
                  left: 5,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(buildContext);
                    },
                    onDoubleTap: () {},
                    child: Container(
                      margin: EdgeInsets.only(
                          top: 50,
                          left: 10),
                      child: Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                      height: 100,
                      color: const Color.fromRGBO(0, 0, 0, 135)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
