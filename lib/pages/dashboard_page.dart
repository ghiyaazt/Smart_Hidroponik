import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPlant = "Sawi";
  double currentPPM = 850.0;
  List<Note> notes = [];

  late Map<String, Map<String, dynamic>> plantData;

  @override
  void initState() {
    super.initState();
    plantData = {
      "Sawi": {
        "scientificName": "Brassica juncea",
        "standardPPM": "800-1200",
        "description": "Sayuran daun yang tumbuh cepat",
        "imageUrl": "https://images.unsplash.com/photo-1567306226416-28f0efdc88ce",
      },
      "Selada": {
        "scientificName": "Lactuca sativa",
        "standardPPM": "560-840",
        "description": "Sayuran daun segar untuk salad",
        "imageUrl": "https://images.unsplash.com/photo-1594282418426-1f7ba964ecc5",
      },
      "Bayam": {
        "scientificName": "Amaranthus spp.",
        "standardPPM": "1260-1610",
        "description": "Sayuran kaya zat besi",
        "imageUrl": "https://images.unsplash.com/photo-1576045057995-568f588f82fb",
      },
    };
  }

  void _showKnowledgeDialog(BuildContext context) {
    final plantInfo = plantData[selectedPlant]!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pengetahuan $selectedPlant", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Nama Ilmiah:", plantInfo['scientificName']),
            _buildInfoRow("PPM Standar:", plantInfo['standardPPM']),
            _buildInfoRow("PPM Saat Ini:", currentPPM.toStringAsFixed(0)),
            const SizedBox(height: 8),
            Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
            Text(plantInfo['description'], style: TextStyle(color: Colors.grey[700])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantInfo = plantData[selectedPlant]!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[800]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 24),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang,",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "My Garden",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildGardenCard(context, plantInfo)),
            SliverToBoxAdapter(child: _buildShortcuts(context)),
            SliverToBoxAdapter(child: _buildRecentNotes()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedPlant,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
            isExpanded: true,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            items: plantData.keys
                .map((plant) => DropdownMenuItem(
                      value: plant,
                      child: Text(
                        plant,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedPlant = value;
                  final range = plantData[value]!['standardPPM'].split('-');
                  currentPPM = (double.parse(range[0]) + double.parse(range[1])) / 2;
                });
              }
            },
            hint: const Text("Pilih Tanaman"),
          ),
        ),
      ),
    );
  }

  Widget _buildGardenCard(BuildContext context, Map<String, dynamic> plantInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plantInfo['scientificName'],
                    style: TextStyle(
                      color: Colors.green[700],
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[500]!, Colors.green[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "PPM: ${currentPPM.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                selectedPlant.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showKnowledgeDialog(context),
                      icon: const Icon(Icons.info_outline, size: 20),
                      label: const Text("Plant Info"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(plantInfo['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcuts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _shortcutButton(Icons.notes, "Notes", Colors.green[100]!, Colors.green, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotesPage(
                  notes: notes, 
                  onNoteAdded: (note) {
                    setState(() {
                      notes.add(note);
                    });
                  },
                  onNoteDeleted: (note) {
                    setState(() {
                      notes.remove(note);
                    });
                  },
                )));
              }),
              _shortcutButton(Icons.calendar_today, "Calendar", Colors.blue[100]!, Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()));
              }),
              _shortcutButton(Icons.notifications, "Reminders", Colors.orange[100]!, Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderPage()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortcutButton(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Notes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (notes.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => NotesPage(
                      notes: notes, 
                      onNoteAdded: (note) {
                        setState(() {
                          notes.add(note);
                        });
                      },
                      onNoteDeleted: (note) {
                        setState(() {
                          notes.remove(note);
                        });
                      },
                    )));
                  },
                  child: const Text("View All", style: TextStyle(color: Colors.green)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.note_add, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    "No notes yet",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NotesPage(
                        notes: notes, 
                        onNoteAdded: (note) {
                          setState(() {
                            notes.add(note);
                          });
                        },
                        onNoteDeleted: (note) {
                          setState(() {
                            notes.remove(note);
                          });
                        },
                      )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Create First Note"),
                  ),
                ],
              ),
            )
          else
            ...notes.take(3).map((note) => _buildNoteItem(note)),
        ],
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(note.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (note.garden.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(note.garden),
                backgroundColor: Colors.green[50],
                labelStyle: TextStyle(color: Colors.green[800]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Note {
  final String title;
  final String content;
  final DateTime date;
  final String garden;

  Note({
    required this.title,
    required this.content,
    required this.date,
    this.garden = "",
  });
}

class NotesPage extends StatefulWidget {
  final List<Note> notes;
  final Function(Note) onNoteAdded;
  final Function(Note) onNoteDeleted;

  const NotesPage({
    super.key, 
    required this.notes, 
    required this.onNoteAdded,
    required this.onNoteDeleted,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notes = List.from(widget.notes);
  }

  void _filterNotes(String query) {
    setState(() {
      notes = widget.notes.where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
               note.content.toLowerCase().contains(query.toLowerCase()) ||
               note.garden.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showAddNoteDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController gardenController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Create note"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Content",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: gardenController,
                    decoration: const InputDecoration(
                      labelText: "Garden (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                    final newNote = Note(
                      title: titleController.text,
                      content: contentController.text,
                      date: selectedDate,
                      garden: gardenController.text,
                    );
                    widget.onNoteAdded(newNote);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onNoteDeleted(note);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note has been deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search notes...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterNotes,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: Key(note.title + note.date.toString()),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteNote(note);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNote(note),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(note.content),
                          if (note.garden.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(note.garden),
                              backgroundColor: Colors.green[50],
                              labelStyle: TextStyle(color: Colors.green[800]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> events = {
    DateTime(2025, 5, 8): ["Water plants", "Check PPM levels"],
    DateTime(2025, 5, 10): ["Add nutrients", "Prune leaves"],
    DateTime(2025, 5, 15): ["Harvest Sawi"],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar History"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(2025, 1, 1),
              lastDay: DateTime(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomRight,
                markersAutoAligned: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.green),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.green),
                titleTextStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              eventLoader: (day) => events[day] ?? [],
            ),
          ),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final eventsForSelectedDay = events[_selectedDay] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Events on ${DateFormat('EEEE, MMMM d, y').format(_selectedDay!)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (eventsForSelectedDay.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text(
                      "No events scheduled for this day",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: eventsForSelectedDay.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(eventsForSelectedDay[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_alert, color: Colors.green),
                        onPressed: () {
                          // Add reminder functionality
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                _showAddEventDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Add New Event"),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Event"),
        content: TextField(
          controller: eventController,
          decoration: const InputDecoration(
            labelText: "Event Description",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                setState(() {
                  if (events.containsKey(_selectedDay)) {
                    events[_selectedDay]!.add(eventController.text);
                  } else {
                    events[_selectedDay!] = [eventController.text];
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminder"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Reminders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Daily Checkup",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Automatic reminder every day at 6 AM"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text("Add New Reminder"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}