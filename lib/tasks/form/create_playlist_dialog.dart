import 'package:flutter/material.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePlaylistDialog extends StatefulWidget {
  final TaskFormCubit taskFormCubit;

  const CreatePlaylistDialog({super.key, required this.taskFormCubit});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  String _playlistName = '';
  bool _isPublic = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createPlaylist),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration:
                InputDecoration(labelText: AppLocalizations.of(context)!.name),
            onChanged: (value) {
              setState(() {
                _playlistName = value;
              });
            },
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(AppLocalizations.of(context)!.public),
              const Spacer(),
              Checkbox(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value ?? false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            widget.taskFormCubit.createPlaylist(_playlistName, _isPublic);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.create),
        ),
      ],
    );
  }
}
