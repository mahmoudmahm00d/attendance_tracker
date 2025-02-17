import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PDFData {
  final String data;
  final String name;

  PDFData({required this.data, required this.name});
}

enum BarcodeSize { small, medium, large }

Future<Uint8List> generatePDF(
  String title,
  List<PDFData> data, {
  bool isArabic = false,
  BarcodeSize size = BarcodeSize.small,
}) async {
  if (data.isEmpty) throw Exception("data is required");
  var pdf = Document();

  double containerSize = size == BarcodeSize.medium ? 140 : 80;
  int itemsInPage = size == BarcodeSize.medium ? 12 : 30;
  int rowsCount = size == BarcodeSize.medium ? 4 : 6;
  int rowsItems = size == BarcodeSize.medium ? 3 : 5;

  int pagesCount = (data.length / itemsInPage).ceil();
  List<Widget> rows = [];
  List<Widget> currentRow = [];
  for (var i = 0; i < data.length; i++) {
    currentRow.add(
      Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2),
        ),
        width: containerSize + 16,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              child: BarcodeWidget(
                data: data[i].data,
                barcode: Barcode.qrCode(),
                drawText: true,
                backgroundColor: const PdfColor(1, 1, 1),
                color: const PdfColor(0, 0, 0),
              ),
            ),
            SizedBox(height: 4),
            Text(
              textAlign: TextAlign.center,
              data[i].name,
              style: TextStyle(fontSize: size == BarcodeSize.medium ? 10 : 8),
            ),
          ],
        ),
      ),
    );

    if (currentRow.length == rowsItems) {
      rows.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: currentRow,
          ),
        ),
      );
      currentRow = [];
    }
  }

  if (currentRow.isNotEmpty) {
    rows.add(
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: currentRow,
        ),
      ),
    );
  }

  final arabicFont =
      Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf"));

  for (var pageIndex = 0; pageIndex < pagesCount; pageIndex++) {
    var start = pageIndex * rowsCount;
    var end = start + rowsCount;
    if (rows.length - 1 < end) {
      end = rows.length;
    }

    var currentList = rows.sublist(start, end);
    if (pageIndex == 0) {
      currentList.insert(
        0,
        Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      currentList.insert(1, SizedBox(height: 16));
    } else {
      currentList.insert(0, SizedBox(height: 16));
    }
    pdf.addPage(
      Page(
        theme: isArabic ? ThemeData.withFont(base: arabicFont) : null,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          if (isArabic) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: currentList,
              ),
            );
          }
          return Column(
            children: currentList,
          );
        },
      ),
    );
  }
  return await pdf.save();
}
