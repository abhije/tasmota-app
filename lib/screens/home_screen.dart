import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tasmota/data/models/device_type.dart';
import 'package:tasmota/notifiers/device_list_notifier.dart';
import 'package:tasmota/notifiers/device_notifier.dart';
import 'package:tasmota/screens/new_device_screen.dart';
import '../data/models/device.dart';

//------------------------------------------------------------------------------
//-- CONTROLLERS --
//------------------------------------------------------------------------------

final deviceListController =
    StateNotifierProvider<DeviceListNotifier, AsyncValue<List<Device>>>(
        (ref) => DeviceListNotifier(ref.read));

final deviceController =
    StateNotifierProvider.family<DeviceNotifier, AsyncValue<bool>, Device>(
        (ref, device) => DeviceNotifier(device));

//------------------------------------------------------------------------------
//-- DEVICE TYPES --
//------------------------------------------------------------------------------

final deviceTypes = [
  DeviceType(
      slug: "fav",
      singularName: "Fav",
      pluralName: "Favourites",
      icon: Icons.star),
  DeviceType(
      slug: "light",
      singularName: "Light",
      pluralName: "Lights",
      icon: Icons.light),
  DeviceType(
      slug: "appl",
      singularName: "Appliance",
      pluralName: "Appliances",
      icon: Icons.home),
  DeviceType(
      slug: "switch",
      singularName: "Switch",
      pluralName: "Switches",
      icon: Icons.login)
];

//------------------------------------------------------------------------------
//-- HOME SCREEN --
//------------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

//------------------------------------------------------------------------------
//-- HOME SCREEN STATE --
//------------------------------------------------------------------------------

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int destinationIndex = 0;

  @override
  Widget build(BuildContext context) {
    final deviceListCtrl = ref.watch(deviceListController);
    return Scaffold(
      appBar: _appBar(context),
      body: deviceListCtrl.when(
        data: (devices) => _deviceList(context, devices),
        error: (error, stackTrace) => const Center(
          child: Text("Oops"),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: _navigationBar(context),
    );
  }

//-- App Bar -------------------------------------------------------------------

  AppBar _appBar(BuildContext context) {
    var actionItems = <Widget>[];
    if (destinationIndex != 0) {
      var addAction = InkWell(
        onTap: () => _openNewDeviceScreen(context),
        child: const Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Icon(Icons.add),
        ),
      );

      actionItems.add(addAction);
    }
    return AppBar(
      title: const Text("Tasmota"),
      actions: actionItems,
    );
  }

//-- Navigation bar ------------------------------------------------------------

  NavigationBar _navigationBar(BuildContext context) {
    var destinations = <NavigationDestination>[];
    for (var el in deviceTypes) {
      var dest =
          NavigationDestination(icon: Icon(el.icon), label: el.pluralName);
      destinations.add(dest);
    }

    return NavigationBar(
        selectedIndex: destinationIndex,
        onDestinationSelected: (int index) {
          setState(() {
            destinationIndex = index;
            final ctrl = ref.read(deviceListController.notifier);
            if (destinationIndex == 0) {
              ctrl.getFavouriteDevices();
            } else {
              ctrl.getDevicesByType(destinationIndex);
            }
          });
        },
        destinations: destinations);
  }

//-- Device List ---------------------------------------------------------------

  Widget _deviceList(BuildContext context, List<Device> devices) {
    return ListView.separated(
        itemCount: devices.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          var item = devices[index],
              deviceType = deviceTypes[item.deviceTypeIndex];

          if (destinationIndex != 0) {
            return ListTile(
              title: Text(item.name),
              subtitle: Text(deviceType.singularName),
              trailing: _actionIcon(context, item),
              onLongPress: () => _editDevice(context, item),
            );
          } else {
            return ListTile(
                title: Text(item.name),
                subtitle: Text(deviceType.singularName),
                trailing: _actionIcon(context, item));
          }
        });
  }

//-- Action Icon ---------------------------------------------------------------

  Widget _actionIcon(BuildContext context, Device device) {
    const double iconSize = 32;
    return Consumer(builder: (context, ref, child) {
      AsyncValue<bool> deviceStat = ref.watch(deviceController(device));
      return deviceStat.when(data: (stat) {
        return InkWell(
          onTap: () {
            final ctrl = ref.read(deviceController(device).notifier);
            ctrl.toggle();
          },
          child: Icon(
            Icons.circle,
            color: stat == true ? Colors.green : Colors.red,
            size: iconSize,
          ),
        );
      }, error: (err, stack) {
        return const Icon(
          Icons.circle,
          color: Colors.orange,
          size: iconSize,
        );
      }, loading: () {
        return const Icon(
          Icons.circle,
          color: Colors.grey,
          size: iconSize,
        );
      });
    });
  }

//-- Open new device screen ----------------------------------------------------

  Future<dynamic> _openNewDeviceScreen(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              children: <Widget>[
                NewDeviceScreen(
                  deviceTypeIndex: destinationIndex,
                )
              ],
            ),
          );
        });
  }

//-- Edit Device Action --------------------------------------------------------

  Future<dynamic> _editDevice(BuildContext context, Device device) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              children: <Widget>[
                NewDeviceScreen(
                  device: device,
                  deviceTypeIndex: destinationIndex,
                )
              ],
            ),
          );
        });
  }
}
