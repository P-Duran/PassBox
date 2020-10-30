import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/model/model.dart';
import 'package:passbox/model/pass_info.dart';
import 'package:passbox/model/provider.dart';
import 'package:passbox/widgets/custom_dropdown.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PassCreatorScreen extends StatefulWidget {
  final String data;
  final String tag;

  const PassCreatorScreen({Key key, this.data, this.tag}) : super(key: key);

  @override
  _PassCreatorScreen createState() => new _PassCreatorScreen();
}

class FieldFormContainer {
  int numberFields = 1;
  List<Field> fields = [];
}

class _PassCreatorScreen extends State<PassCreatorScreen> {
  final _formKey = GlobalKey<FormState>();

  FieldFormContainer titleContainer = FieldFormContainer();
  FieldFormContainer primaryContainer = FieldFormContainer();
  FieldFormContainer secondaryContainer = FieldFormContainer();
  PassType passType = PassType.none;
  Color currentColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: currentColor,
        child: Icon(
          Icons.save,
          color: useWhiteForeground(currentColor)
              ? const Color(0xffffffff)
              : const Color(0xff000000),
        ),
        onPressed: () async {
          if (!_formKey.currentState.validate()) return;
          if (passType == PassType.none) {
            toast("please select a passbook type");
            return;
          }
          _formKey.currentState.save();
          await Model.createPkpass(PassInfo(
              primaryFields: primaryContainer.fields,
              secondaryFields: secondaryContainer.fields,
              headerFields: titleContainer.fields,
              type: passType,
              labelColor: currentColor,
              bcImage: BarcodeImage(widget.data, Barcode.qrCode())));
          toast("PassBook Created");
          PkpassProvider.of(context).value.sendEvent.add(OpenPassesEvent());
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkResponse(
                          onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                titlePadding: const EdgeInsets.all(0.0),
                                contentPadding: const EdgeInsets.all(0.0),
                                content: SingleChildScrollView(
                                  child: MaterialPicker(
                                    pickerColor: currentColor,
                                    onColorChanged: (val) => setState(
                                      () {
                                        currentColor = val;
                                      },
                                    ),
                                    enableLabel: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          child: new Container(
                            width: 45,
                            height: 45,
                            decoration: new BoxDecoration(
                              color: currentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SimpleAccountMenu(
                              selectorIconSize: 40,
                              icons: PassType.values
                                  .map((e) => Icon(Utils.passTypeToIconData(e)))
                                  .toList(),
                              iconText: PassType.values
                                  .map((e) => e.toString().substring(9))
                                  .toList(),
                              onChange: (index) {
                                setState(
                                  () {
                                    passType = PassType.values[index];
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                formFields("PassBook Title", titleContainer),
                formFields("Primary Fields", primaryContainer),
                formFields("Secondary Fields", secondaryContainer),
                BarcodeWidget(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                  barcode: Barcode.qrCode(),
                  data: widget.data,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formFields(String title, FieldFormContainer fieldFormContainer) {
    String value = "";
    String label = "";
    Field fieldToSave = new Field("key", "label", "value");
    List<Widget> widgetList = createFieldList(fieldFormContainer, fieldToSave);
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ]..addAll(widgetList),
      ),
    );
  }

  Widget fieldRow(Field fieldToSave, List<Field> saveDataList) => Row(
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Field Name",
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) => fieldToSave.label = value,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Field Value",
                  labelStyle: TextStyle(color: Colors.blueGrey[700]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  fieldToSave.value = newValue;
                  saveDataList.add(fieldToSave);
                },
              ),
            ),
          ),
        ],
      );
  List<Widget> createFieldList(
      FieldFormContainer fieldFormContainer, Field fieldToSave) {
    List<Widget> list = [];
    for (int i = 0; i < fieldFormContainer.numberFields; i++) {
      list.add(fieldRow(fieldToSave, fieldFormContainer.fields));
    }
    list.add(IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        setState(() {
          fieldFormContainer.numberFields++;
        });
      },
    ));
    return list;
  }
}
