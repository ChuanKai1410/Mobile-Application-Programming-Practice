import 'package:flutter/material.dart';
import '../models/network_recipe.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class NetworkingScreen extends StatefulWidget {
  const NetworkingScreen({super.key});

  @override
  State<NetworkingScreen> createState() => _NetworkingScreenState();
}

class _NetworkingScreenState extends State<NetworkingScreen> {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();

  NetworkRecipe? _currentRecipe;
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _liveUpdates = [];

  final _updateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _wsService.stream.listen((message) {
      setState(() {
        _liveUpdates.insert(0, message);
        if (_liveUpdates.length > 5) {
          _liveUpdates.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _wsService.dispose();
    _updateController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
      if (loading) _errorMessage = null;
    });
  }

  Future<void> _fetchRecipe() async {
    _setLoading(true);
    try {
      final recipe = await _apiService.fetchRecipe();
      setState(() => _currentRecipe = recipe);
      _showSnackBar('Fetched recipe successfully!');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createRecipe() async {
    _setLoading(true);
    try {
      final newRecipe = NetworkRecipe(
        chefId: 99,
        recipeId: 0,
        recipeTitle: 'New Truffle Pasta',
      );
      final created = await _apiService.createRecipe(newRecipe);
      setState(() => _currentRecipe = created);
      _showSnackBar('Created recipe successfully!');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateRecipe() async {
    if (_currentRecipe == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Recipe Title'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _updateController,
              decoration: const InputDecoration(labelText: 'New Title'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Cannot be empty' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _setLoading(true);
                  try {
                    final updated = await _apiService.updateRecipe(
                      _currentRecipe!.recipeId,
                      _updateController.text,
                    );
                    setState(() => _currentRecipe = updated);
                    _showSnackBar('Updated recipe successfully!');
                  } catch (e) {
                    setState(() => _errorMessage = e.toString());
                  } finally {
                    _setLoading(false);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecipe() async {
    if (_currentRecipe == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _setLoading(true);
      try {
        await _apiService.deleteRecipe(_currentRecipe!.recipeId);
        setState(() => _currentRecipe = null);
        _showSnackBar('Deleted recipe successfully!');
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        _setLoading(false);
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Networking & HTTP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),

            // HTTP Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchRecipe,
                  icon: const Icon(Icons.download),
                  label: const Text('GET'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createRecipe,
                  icon: const Icon(Icons.add),
                  label: const Text('POST'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading || _currentRecipe == null
                      ? null
                      : _updateRecipe,
                  icon: const Icon(Icons.edit),
                  label: const Text('PUT/PATCH'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                  ),
                  onPressed: _isLoading || _currentRecipe == null
                      ? null
                      : _deleteRecipe,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Display Recipe
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_currentRecipe != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipe ID: ${_currentRecipe!.recipeId}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chef ID: ${_currentRecipe!.chefId}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentRecipe!.recipeTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(child: Text('No recipe data. Tap GET to fetch.')),

            const SizedBox(height: 32),
            const Divider(),

            // WebSocket Section
            const Text(
              'Live Feed (WebSocket Simulation)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _wsService.connect(),
                  icon: const Icon(Icons.wifi),
                  label: const Text('Connect'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _wsService.disconnect(),
                  icon: const Icon(Icons.wifi_off),
                  label: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _liveUpdates.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '> ${_liveUpdates[index]}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
