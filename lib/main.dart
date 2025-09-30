import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- Data Models ---
class Medicine {
  final String id;
  String name;
  double price;
  int quantity;

  Medicine({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class BillItem {
  final Medicine medicine;
  int quantity;

  BillItem({required this.medicine, required this.quantity});
}

// --- State Management (Providers) ---
class MedicineProvider with ChangeNotifier {
  final List<Medicine> _medicines = [
    Medicine(id: 'm1', name: 'Aspirin', price: 5.99, quantity: 100),
    Medicine(id: 'm2', name: 'Ibuprofen', price: 7.49, quantity: 80),
    Medicine(id: 'm3', name: 'Paracetamol', price: 4.99, quantity: 120),
    Medicine(id: 'm4', name: 'Amoxicillin', price: 12.00, quantity: 50),
  ];

  List<Medicine> get medicines => [..._medicines];

  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    notifyListeners();
  }

  void updateMedicine(Medicine medicine) {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
      notifyListeners();
    }
  }

  void deleteMedicine(String id) {
    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}

class BillProvider with ChangeNotifier {
  final List<BillItem> _billItems = [];

  List<BillItem> get billItems => [..._billItems];

  double get totalAmount {
    return _billItems.fold(
      0.0,
      (sum, item) => sum + (item.medicine.price * item.quantity),
    );
  }

  void addToBill(Medicine medicine, int quantity) {
    final existingIndex = _billItems.indexWhere(
      (item) => item.medicine.id == medicine.id,
    );
    if (existingIndex != -1) {
      _billItems[existingIndex].quantity += quantity;
    } else {
      _billItems.add(BillItem(medicine: medicine, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromBill(String medicineId) {
    _billItems.removeWhere((item) => item.medicine.id == medicineId);
    notifyListeners();
  }

  void clearBill() {
    _billItems.clear();
    notifyListeners();
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}

// --- Main Application ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MedicineProvider()),
        ChangeNotifierProvider(create: (context) => BillProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor primarySeedColor = Colors.teal;

    final appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Medicine Billing Software',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

// --- Screens ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    BillingScreen(),
    InventoryScreen(),
  ];

  static const List<String> _titles = <String>[
    'Medicine Billing',
    'Inventory',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final medicineProvider = Provider.of<MedicineProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: billProvider.billItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items in the bill. Add some from the inventory!',
                    ),
                  )
                : ListView.builder(
                    itemCount: billProvider.billItems.length,
                    itemBuilder: (context, index) {
                      final item = billProvider.billItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text((index + 1).toString()),
                          ),
                          title: Text(
                            item.medicine.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Qty: ${item.quantity} @ \$${item.medicine.price.toStringAsFixed(2)}',
                          ),
                          trailing: Text(
                            '\$${(item.medicine.price * item.quantity).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          onLongPress: () {
                            billProvider.removeFromBill(item.medicine.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item.medicine.name} removed from bill.',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '\$${billProvider.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: billProvider.billItems.isEmpty
                  ? null
                  : () => _showBillGeneratedDialog(context, billProvider),
              icon: const Icon(Icons.receipt),
              label: const Text('Generate Bill'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddMedicineDialog(context, medicineProvider, billProvider),
        tooltip: 'Add Medicine to Bill',
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _showAddMedicineDialog(
    BuildContext context,
    MedicineProvider medicineProvider,
    BillProvider billProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        Medicine? selectedMedicine;
        final quantityController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Medicine to Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Medicine>(
                hint: const Text('Select Medicine'),
                items: medicineProvider.medicines.map((medicine) {
                  return DropdownMenuItem<Medicine>(
                    value: medicine,
                    child: Text(medicine.name),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedMedicine = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Medicine',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedMedicine != null &&
                    quantityController.text.isNotEmpty) {
                  final quantity = int.tryParse(quantityController.text);
                  if (quantity != null && quantity > 0) {
                    billProvider.addToBill(selectedMedicine!, quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${selectedMedicine!.name} added to bill.',
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showBillGeneratedDialog(
    BuildContext context,
    BillProvider billProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bill Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Amount:'),
              Text(
                '\$${billProvider.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text('Thank you for your purchase!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                billProvider.clearBill();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicineProvider = Provider.of<MedicineProvider>(context);

    return Scaffold(
      body: medicineProvider.medicines.isEmpty
          ? const Center(
              child: Text(
                'No medicines in inventory. Add some to get started!',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: medicineProvider.medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicineProvider.medicines[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text('Quantity: ${medicine.quantity}'),
                    trailing: Text(
                      '\$${medicine.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    onTap: () => _showAddEditMedicineDialog(
                      context,
                      medicineProvider,
                      medicine: medicine,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditMedicineDialog(context, medicineProvider),
        tooltip: 'Add New Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditMedicineDialog(
    BuildContext context,
    MedicineProvider medicineProvider, {
    Medicine? medicine,
  }) {
    final isEditing = medicine != null;
    final nameController = TextEditingController(
      text: isEditing ? medicine.name : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? medicine.price.toString() : '',
    );
    final quantityController = TextEditingController(
      text: isEditing ? medicine.quantity.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            if (isEditing)
              TextButton(
                onPressed: () {
                  medicineProvider.deleteMedicine(medicine.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${medicine.name} deleted.')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final price = double.tryParse(priceController.text);
                final quantity = int.tryParse(quantityController.text);

                if (name.isNotEmpty && price != null && quantity != null) {
                  if (isEditing) {
                    medicineProvider.updateMedicine(
                      Medicine(
                        id: medicine.id,
                        name: name,
                        price: price,
                        quantity: quantity,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${medicine.name} updated.')),
                    );
                  } else {
                    final newId = 'm${DateTime.now().millisecondsSinceEpoch}';
                    medicineProvider.addMedicine(
                      Medicine(
                        id: newId,
                        name: name,
                        price: price,
                        quantity: quantity,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name added to inventory.')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
