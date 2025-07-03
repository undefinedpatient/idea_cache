import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';

class ICCreateCacheForm extends StatefulWidget {
  const ICCreateCacheForm({super.key, required Function() onCancel})
    : _onCancel = onCancel;
  final Function() _onCancel;
  @override
  State<StatefulWidget> createState() {
    return _ICCreateCacheForm(onCancel: _onCancel);
  }
}

class _ICCreateCacheForm extends State<ICCreateCacheForm> {
  _ICCreateCacheForm({required Function() onCancel}) : _onCancel = onCancel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Function() _onCancel;
  String _name = "";
  String _description = "";

  void _submitForm() async {
    log("called", name: "_ICCreateCacheForm._submitForm()");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      _onCancel();
    }
    await Cache.writeCounter(1);
    await Cache.readCounter().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(128, 64, 128, 64),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 16.0,
          children: [
            Text("Create New Cache", style: TextStyle(fontSize: 32)),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Cache Name",
                border: OutlineInputBorder(borderSide: BorderSide(width: 4)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Thie field cannot be empty";
                }
                return null;
              },
              onSaved: (newValue) {
                log("New name $newValue has been saved");
                _name = (newValue != null) ? newValue : "";
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(borderSide: BorderSide(width: 4)),
              ),
              validator: (value) {
                return null;
              },
              onSaved: (newValue) {
                log("New id $newValue has been saved");
                _description = (newValue != null) ? newValue : "";
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16.0,
              children: [
                FilledButton(onPressed: _onCancel, child: Text("Cancel")),
                FilledButton(onPressed: _submitForm, child: Text("Submit")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
