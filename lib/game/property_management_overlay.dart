import 'package:flutter/material.dart';
import '../game_logic/models/player.dart';
import '../game_logic/models/property.dart';
import 'responsive_utils.dart';

class PropertyManagementOverlay extends StatelessWidget {
  final Player player;
  final void Function(Property property) onMortgage;
  final void Function(Property property) onUnmortgage;
  final void Function(Property property) onBuildHouse;
  final void Function(Property property) onBuildHotel;
  final VoidCallback onClose;

  const PropertyManagementOverlay({
    Key? key,
    required this.player,
    required this.onMortgage,
    required this.onUnmortgage,
    required this.onBuildHouse,
    required this.onBuildHotel,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = player.ownedProperties;
    return Center(
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 250),
          child: Semantics(
            label: 'Property Management Overlay',
            explicitChildNodes: true,
            child: Material(
              color: Colors.black54,
              child: Container(
                width: ResponsiveUtils.dialogWidth(context),
                height: ResponsiveUtils.dialogHeight(context),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('My Properties', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (properties.isEmpty)
                      const Text('You do not own any properties.'),
                    if (properties.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: properties.length,
                          itemBuilder: (context, i) {
                            final prop = properties[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(prop.name),
                                subtitle: Text('Houses: \\${prop.houses}  |  Hotel: \\${prop.hasHotel ? "Yes" : "No"}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!prop.isMortgaged)
                                      Semantics(
                                        label: 'Mortgage ${prop.name}',
                                        button: true,
                                        child: IconButton(
                                          icon: const Icon(Icons.account_balance),
                                          tooltip: 'Mortgage',
                                          onPressed: () => onMortgage(prop),
                                        ),
                                      ),
                                    if (prop.isMortgaged)
                                      Semantics(
                                        label: 'Unmortgage ${prop.name}',
                                        button: true,
                                        child: IconButton(
                                          icon: const Icon(Icons.money_off),
                                          tooltip: 'Unmortgage',
                                          onPressed: () => onUnmortgage(prop),
                                        ),
                                      ),
                                    if (!prop.isMortgaged && !prop.hasHotel)
                                      Semantics(
                                        label: 'Build house on ${prop.name}',
                                        button: true,
                                        child: IconButton(
                                          icon: const Icon(Icons.add_home),
                                          tooltip: 'Build House',
                                          onPressed: () => onBuildHouse(prop),
                                        ),
                                      ),
                                    if (!prop.isMortgaged && prop.houses == 4 && !prop.hasHotel)
                                      Semantics(
                                        label: 'Build hotel on ${prop.name}',
                                        button: true,
                                        child: IconButton(
                                          icon: const Icon(Icons.apartment),
                                          tooltip: 'Build Hotel',
                                          onPressed: () => onBuildHotel(prop),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    Semantics(
                      label: 'Close property management overlay',
                      button: true,
                      child: ElevatedButton(
                        onPressed: onClose,
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
