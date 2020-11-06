import 'dart:io';

class EntityInfo {
  FileSystemEntity entity;
  FileStat stat;
  List<FileSystemEntity> children = [];
  EntityType entityType;

  EntityInfo({
    this.entity,
    this.stat,
    this.children,
    this.entityType,
  });

  bool get isDirectory => entityType == EntityType.DIRECTORY;

  String get path => entity.path;
}

enum EntityType {
  FILE,
  DIRECTORY,
}