import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:idea_cache/model/block.dart';
import 'package:idea_cache/model/filehandler.dart';

class ICImportDocumentView extends StatefulWidget {
  final QuillController quillController;
  const ICImportDocumentView({super.key, required this.quillController});

  @override
  State<ICImportDocumentView> createState() => _ICImportDocumentViewState();
}

class _ICImportDocumentViewState extends State<ICImportDocumentView> {
  String selectedFileName = "No file selected";
  List<ICBlock> blocks = List.empty(growable: true);
  int selectedBlockIndex = -1;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Clamping
      height: (MediaQuery.of(context).size.height < 600)
          ? MediaQuery.of(context).size.height - 24
          : 600,
      width: (MediaQuery.of(context).size.width < 800)
          ? MediaQuery.of(context).size.width - 96
          : 800,
      //
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          title: Text("Import Document"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Select File: $selectedFileName"),
                    IconButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              allowMultiple: false,
                              allowedExtensions: ["json"],
                            );

                        if (result != null) {
                          File file = File(result.files.single.path!);
                          List<ICBlock> readBlocks;
                          try {
                            readBlocks = await FileHandler.readBlocks(
                              dataString: file.readAsStringSync(),
                            );
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Incorrect file format.\n"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("ok"),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }
                          setState(() {
                            selectedFileName = file.path;
                          });
                          setState(() {
                            blocks = readBlocks;
                          });
                        }
                      },
                      icon: const Icon(Icons.folder),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: ListView(
                    shrinkWrap: true,
                    children: blocks
                        .asMap()
                        .entries
                        .map(
                          (entry) => ListTile(
                            onTap: () {
                              setState(() {
                                selectedBlockIndex = entry.key;
                              });
                              log("index:$selectedBlockIndex");
                            },
                            title: Text(entry.value.name),
                            subtitle: Text("Cache Id: ${entry.value.cacheId}"),
                            selected: selectedBlockIndex == entry.key,
                            trailing: (selectedBlockIndex == entry.key)
                                ? Text("Selected")
                                : Text(""),
                            selectedTileColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Text("Currently only default block.json format is supported"),
              TextButton(
                onPressed: () {
                  if (selectedBlockIndex != -1 && blocks.isNotEmpty) {
                    ICBlock block = blocks[selectedBlockIndex];
                    // If the content is Empty, skip it to avoid error
                    if (block.content.isEmpty) {
                      Navigator.of(context).pop();
                      return;
                    }
                    widget.quillController.document = Document.fromJson(
                      jsonDecode(block.content),
                    );
                  }

                  Navigator.of(context).pop();
                },
                child: Text("Import"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
