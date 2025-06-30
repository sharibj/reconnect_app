class Group {
  final String name;
  final int frequencyInDays;

  Group({
    required this.name,
    required this.frequencyInDays,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
      frequencyInDays: json['frequencyInDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'frequencyInDays': frequencyInDays,
    };
  }
}