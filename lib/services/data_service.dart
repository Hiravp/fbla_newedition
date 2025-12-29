class DataService {
  Future<List<String>> fetchItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Item 1', 'Item 2', 'Item 3'];
  }
}
