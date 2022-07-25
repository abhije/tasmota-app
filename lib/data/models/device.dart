import 'package:objectbox/objectbox.dart';

//------------------------------------------------------------------------------
//-- DEVICE --
//------------------------------------------------------------------------------

@Entity()
class Device {
  int id;

  final String name;
  final String ip;
  final int deviceId;
  final String? apiPasswd;

  @Index()
  final int deviceTypeIndex;

  @Index()
  bool isFav;

  Device(
      {this.id = 0,
      required this.name,
      required this.ip,
      required this.deviceId,
      this.apiPasswd,
      required this.deviceTypeIndex,
      this.isFav = false});
}
