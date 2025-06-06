import 'package:hive/hive.dart';
import '../models/enums.dart';
import '../models/player.dart';
import '../models/property.dart';

part 'hive_adapters.g.dart';

@HiveType(typeId: 0)
enum GameStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  active,
  @HiveField(2)
  completed,
}

@HiveType(typeId: 1)
class Player {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int tokenId;

  @HiveField(2)
  int position;

  @HiveField(3)
  double balance;

  @HiveField(4)
  bool inJail;

  @HiveField(5)
  int jailTurns;

  @HiveField(6)
  int getOutOfJailCards;

  @HiveField(7)
  List<Property> ownedProperties;

  @HiveField(8)
  bool isBankrupt;

  Player({
    required this.name,
    required this.tokenId,
    this.position = 0,
    this.balance = 1500.0,
    this.inJail = false,
    this.jailTurns = 0,
    this.getOutOfJailCards = 0,
    List<Property>? ownedProperties,
    this.isBankrupt = false,
  }) : ownedProperties = ownedProperties ?? [];
}

@HiveType(typeId: 2)
class Property {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double price;

  @HiveField(2)
  final double baseRent;

  @HiveField(3)
  final int colorGroup;

  @HiveField(4)
  bool isMortgaged;

  @HiveField(5)
  int houses;

  @HiveField(6)
  bool hasHotel;

  Property({
    required this.name,
    required this.price,
    required this.baseRent,
    required this.colorGroup,
    this.isMortgaged = false,
    this.houses = 0,
    this.hasHotel = false,
  });
}