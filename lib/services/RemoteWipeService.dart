


import 'package:untitled1/services/StorageSecure.dart';

class Remotewipeservice {
  final Storagesecure _storage = Storagesecure();


  Future<void> execute(String userId) async {
    final data = await _storage.getData();

    if (data == null) {
      return;
    }
    print("USER ID $userId");

    if (data.Id ==  userId) {
      await _storage.delete();

      print("DATOS SENSIBLES ELIMINADOS");
    }
  }
}