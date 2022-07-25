import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasmota/data/models/device.dart';
import 'package:tasmota/main.dart';
import 'package:tasmota/objectbox.g.dart';

//------------------------------------------------------------------------------
//-- DEVICE LIST NOTIFIER --
//------------------------------------------------------------------------------

class DeviceListNotifier extends StateNotifier<AsyncValue<List<Device>>> {
  DeviceListNotifier(this.read) : super(const AsyncLoading()) {
    getFavouriteDevices();
  }

  final Reader read;

//-- Get favourite devices -----------------------------------------------------

  void getFavouriteDevices() {
    final store = read(objectboxProvider).store;
    final deviceBox = store.box<Device>();
    QueryBuilder<Device> queryBuilder =
        deviceBox.query(Device_.isFav.equals(true))..order(Device_.name);
    Query<Device> query = queryBuilder.build();
    state = AsyncData(query.find());
    query.close();
  }

//-- Get device by type --------------------------------------------------------

  void getDevicesByType(int deviceTypeIndex) {
    final store = read(objectboxProvider).store;
    final box = store.box<Device>();
    QueryBuilder<Device> queryBuilder = box
        .query(Device_.deviceTypeIndex.equals(deviceTypeIndex))
      ..order(Device_.name);
    Query<Device> query = queryBuilder.build();
    state = AsyncData(query.find());
    query.close();
  }

//-- Add Device ----------------------------------------------------------------

  void save(Device device) {
    final store = read(objectboxProvider).store;
    final box = store.box<Device>();
    box.put(device);
    getDevicesByType(device.deviceTypeIndex);
  }

//-- Remove Device -------------------------------------------------------------

  void remove(Device device, int deviceTypeIndex) {
    final store = read(objectboxProvider).store;
    final box = store.box<Device>();
    Query<Device> _query = box.query(Device_.id.equals(device.id)).build();
    Device? _device = _query.findFirst();
    if (_device != null) {
      _query.remove();
      if (deviceTypeIndex == 0) {
        getFavouriteDevices();
      } else {
        getDevicesByType(deviceTypeIndex);
      }
    }
    _query.close();
  }
}
