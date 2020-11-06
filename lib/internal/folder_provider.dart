import 'package:flutter/material.dart';
import 'package:xdg_directories/xdg_directories.dart';

class FolderProvider {
  List<MapEntry<String, IconData>> directories = [];

  FolderProvider() {
    final dirNames = getUserDirectoryNames();
    dirNames.forEach((element) {
      directories.add(
        MapEntry(
          getUserDirectory(element).path,
          icons[element],
        ),
      );
    });

    List<String> backDir = directories[0].key.split("/")..removeLast();
    directories.insert(
      0,
      MapEntry(
        backDir.join("/"),
        icons["HOME"],
      ),
    );
    //directories.sort((a, b) => a.key.compareTo(b.key));
  }
}

const Map<String, IconData> icons = {
  "HOME": Icons.home_filled,
  "DESKTOP": Icons.desktop_windows,
  "DOCUMENTS": Icons.note_outlined,
  "PICTURES": Icons.photo_library_outlined,
  "DOWNLOAD": Icons.file_download,
  "VIDEOS": Icons.videocam_outlined,
  "MUSIC": Icons.music_note_outlined,
  "PUBLICSHARE": Icons.public_outlined,
  "TEMPLATES": Icons.file_copy_outlined,
};
