enum StandardType { pmbok, prince2, iso21500, iso21502 }

class Standard {
  final StandardType type;
  final String name;
  final String version;
  final String pdfPath;
  final String description;
  final String color;

  const Standard({
    required this.type,
    required this.name,
    required this.version,
    required this.pdfPath,
    required this.description,
    required this.color,
  });

  factory Standard.fromJson(Map<String, dynamic> json) {
    return Standard(
      type: StandardType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
      ),
      name: json['name'],
      version: json['version'],
      pdfPath: json['pdfPath'],
      description: json['description'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'name': name,
      'version': version,
      'pdfPath': pdfPath,
      'description': description,
      'color': color,
    };
  }
}
