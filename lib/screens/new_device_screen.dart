import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logger/logger.dart';
import 'package:tasmota/data/models/device.dart';
import 'package:tasmota/screens/home_screen.dart';

//------------------------------------------------------------------------------
//-- NEW DEVICE SCREEN --
//------------------------------------------------------------------------------

class NewDeviceScreen extends ConsumerStatefulWidget {
  const NewDeviceScreen({Key? key, this.device, required this.deviceTypeIndex})
      : super(key: key);

  final Device? device;
  final int deviceTypeIndex;

  @override
  ConsumerState<NewDeviceScreen> createState() => _NewDeviceScreenState();
}

//------------------------------------------------------------------------------
//-- NEW DEVICE SCREEN STATE --
//------------------------------------------------------------------------------

class _NewDeviceScreenState extends ConsumerState<NewDeviceScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    var btnRowChildren = <Widget>[
      const SizedBox(width: 12),
      Expanded(child: _resetButton(context)),
      const SizedBox(width: 12),
      Expanded(child: _saveButton(context)),
      const SizedBox(width: 12),
    ];

    if (widget.device != null) {
      var dbtn = Expanded(child: _deleteButton(context, widget.device!));
      btnRowChildren.insert(1, dbtn);
      btnRowChildren.insert(2, const SizedBox(width: 12));
    }

    var deviceType = deviceTypes[widget.deviceTypeIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            widget.device != null
                ? "Edit Device"
                : 'New ${deviceType.singularName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                _nameField(context),
                _ipField(context),
                _deviceIDField(context),
                _apiPasswdField(context),
                _isFavField(context)
              ],
            )),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(children: btnRowChildren),
        )
      ],
    );
  }

//-- Name Field ------------------------------------------------------------------

  Widget _nameField(BuildContext context) {
    return FormBuilderTextField(
      name: 'name',
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(labelText: 'Name'),
      keyboardType: TextInputType.name,
      initialValue: widget.device?.name,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.maxLength(50),
        FormBuilderValidators.minLength(2)
      ]),
    );
  }

//-- IP Field ------------------------------------------------------------------

  Widget _ipField(BuildContext context) {
    return FormBuilderTextField(
      name: 'ip',
      decoration: const InputDecoration(labelText: 'IP Address'),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      initialValue: widget.device?.ip,
      validator: FormBuilderValidators.compose(
          [FormBuilderValidators.required(), FormBuilderValidators.ip()]),
    );
  }

//-- Device ID field -----------------------------------------------------------

  Widget _deviceIDField(BuildContext context) {
    return FormBuilderTextField(
      name: 'deviceId',
      decoration: const InputDecoration(labelText: 'Device ID'),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      initialValue: widget.device?.deviceId.toString(),
      validator: FormBuilderValidators.compose(
          [FormBuilderValidators.required(), FormBuilderValidators.numeric()]),
    );
  }

//-- API password field --------------------------------------------------------

  Widget _apiPasswdField(BuildContext context) {
    return FormBuilderTextField(
      name: "apiPasswd",
      decoration: const InputDecoration(labelText: 'Api Password'),
      initialValue: widget.device != null
          ? widget.device!.apiPasswd
          : 'awdLIJ098', //TODO: remove temporary api password
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }

//-- Is Fav field --------------------------------------------------------------

  Widget _isFavField(BuildContext context) {
    return FormBuilderCheckbox(
        name: 'isFav',
        initialValue: widget.device != null ? widget.device!.isFav : false,
        title: const Text("Is favourite?"));
  }

//-- Reset Button --------------------------------------------------------------

  Widget _resetButton(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).colorScheme.tertiary,
      child: Text(
        "Reset",
        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
      ),
      onPressed: () {
        _formKey.currentState!.reset();
      },
    );
  }

//-- Delete Button -------------------------------------------------------------

  Widget _deleteButton(BuildContext context, Device device) {
    return MaterialButton(
        color: Colors.redAccent,
        child: const Text(
          "Delete",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text("Are you sure?"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            var ctrl = ref.read(deviceListController.notifier);
                            ctrl.remove(device, widget.deviceTypeIndex);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text("Delete"))
                    ],
                  ));
        });
  }

//-- Save Button ---------------------------------------------------------------

  Widget _saveButton(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).colorScheme.secondary,
      child: const Text(
        "Save",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        try {
          _formKey.currentState!.save();
          if (_formKey.currentState!.validate()) {
            final formValue = _formKey.currentState!.value;
            final device = Device(
                name: formValue["name"],
                ip: formValue["ip"],
                isFav: formValue["isFav"],
                deviceId: int.parse(formValue["deviceId"]),
                apiPasswd: formValue["apiPasswd"],
                deviceTypeIndex: widget.device != null
                    ? widget.device!.deviceTypeIndex
                    : widget.deviceTypeIndex);
            if (widget.device != null) {
              device.id = widget.device!.id;
            }

            final ctrl = ref.read(deviceListController.notifier);
            ctrl.save(device);
            Navigator.pop(context);
          }
        } catch (e) {
          var logger = Logger();
          logger.e(e);
        }
      },
    );
  }
}
