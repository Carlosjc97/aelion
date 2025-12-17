class ModuleTileState {
  ModuleTileState({
    required this.number,
    required this.title,
    required this.skills,
    required this.unlocked,
    required this.completed,
    required this.requiresPremium,
  });

  final int number;
  final String title;
  final List<String> skills;
  bool unlocked;
  bool completed;
  bool requiresPremium;
}
