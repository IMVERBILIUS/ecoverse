// lib/models/item.dart (Full Code)

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String type;
  final int costGP;
  final String icon;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.costGP,
    required this.icon,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      costGP: json['costGP'],
      icon: json['icon'],
    );
  }
}