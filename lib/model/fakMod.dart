class FakturModel {
  final String invoiceNumber;
  final String date;
  final List<FakturItem> items;
  final int total;
  final int tunai;
  final int kembalian;

  FakturModel(
      {required this.invoiceNumber,
      required this.date,
      required this.items,
      required this.total,
      required this.tunai,
      required this.kembalian});
}

class FakturItem {
  final String description;
  final int price;
  final int quantity;

  FakturItem({
    required this.description,
    required this.price,
    required this.quantity,
  });
}
