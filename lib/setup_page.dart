import 'package:flutter/material.dart';

import 'file_selection.dart';
import 'video_format_selection.dart';
import 'network_selection.dart';
import 'sync_mode_selection.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: NetworkConnectionSection()),
                    Expanded(child: FileManagementSection()),
                  ],
                ),
              ),
              IntrinsicHeight(
                  child: SizedBox(
                      height: 200,
                      // System status overview diagram TODO
                      child: Placeholder())),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // or stretch, depending on your intent
                  children: [
                    Expanded(child: VideoFormatSelectionSection()),
                    SizedBox(
                      width: 400,
                      child: SyncSettingsSection(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
