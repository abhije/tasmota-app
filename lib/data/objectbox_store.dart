import '../objectbox.g.dart';

///-----------------------------------------------------------------------------
/// BOX STORE
///-----------------------------------------------------------------------------

class ObjectBox {
  late final Store store;
  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
}
