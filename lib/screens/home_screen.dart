import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/screens/add_entry_screen.dart';
import 'package:travel_journal/model/home_view_model.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';
import 'package:travel_journal/shared/widgets/main_navbar_widget.dart';
import 'package:travel_journal/shared/widgets/main_title_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const MainTitleWidget(),
        actions: [
          IconButton(
            tooltip: 'New journal entry',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final locationName = await vm.getLocationName();

              if (!context.mounted) return;

              final entry = await Navigator.of(context).push<JournalEntryModel>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => AddEntryScreen(
                    locationName: locationName,
                    initialLatitude: vm.currentMapCenter.latitude,
                    initialLongitude: vm.currentMapCenter.longitude,
                  ),
                ),
              );

              if (!context.mounted) return;

              if (entry != null) {
                await vm.saveEntry(entry);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entry "${entry.title}" saved!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: MainNavbar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: HomeViewModel.initialCameraPosition,
                myLocationEnabled: vm.locationPermissionGranted,
                myLocationButtonEnabled: vm.locationPermissionGranted,
                onMapCreated: vm.onMapCreated,
                onCameraMove: vm.onCameraMove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
