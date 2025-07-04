import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:idea_cache/model/cache.dart';
import 'package:idea_cache/model/fileHandler.dart';

class ICCreateCacheForm extends StatefulWidget {
  const ICCreateCacheForm({super.key, required Function() onExitForm})
    : _onExitForm = onExitForm;
  final Function() _onExitForm;
  @override
  State<StatefulWidget> createState() {
    return _ICCreateCacheForm(onExitForm: _onExitForm);
  }
}

class _ICCreateCacheForm extends State<ICCreateCacheForm> {
  _ICCreateCacheForm({required Function() onExitForm})
    : _onExitForm = onExitForm;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Function() _onExitForm;

  void _submitForm() async {
    log(name: toString(), "_submitForm()");
    Cache newCache = Cache(name: "Untitled");
    FileHandler.writeCache(newCache);

    // if (_formKey.currentState!.validate()) {
    //   Cache newCache = new Cache(name: _nameInForm);
    //   log("Called");
    //   newCache.toJson().forEach((String key, dynamic value) {
    //     log("$key:$value");
    //   });
    // }
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
              onChanged: (newValue) {
                // _nameInForm = newValue;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16.0,
              children: [
                FilledButton(onPressed: _onExitForm, child: Text("Cancel")),
                FilledButton(onPressed: _submitForm, child: Text("Submit")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
