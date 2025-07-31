class Song {
  final String title;
  final String subtitle;
  final String path;

  Song({
    required this.title,
    required this.subtitle,
    required this.path,
  });

  // Optional: helpful for comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          subtitle == other.subtitle &&
          path == other.path;

  @override
  int get hashCode => title.hashCode ^ subtitle.hashCode ^ path.hashCode;
}
