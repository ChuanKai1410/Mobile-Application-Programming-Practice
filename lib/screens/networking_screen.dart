import 'package:flutter/material.dart';

import '../models/network_recipe.dart';
import '../models/spaghetti_dish.dart';
import '../services/api_service.dart';
import '../services/recipe_service.dart';
import '../services/websocket_service.dart';
import '../theme/app_colors.dart';

class NetworkingScreen extends StatefulWidget {
  const NetworkingScreen({super.key});

  @override
  State<NetworkingScreen> createState() => _NetworkingScreenState();
}

class _NetworkingScreenState extends State<NetworkingScreen> {
  final ApiService _apiService = ApiService();
  final RecipeService _recipeService = RecipeService();
  final WebSocketService _wsService = WebSocketService();

  NetworkResponse? _response;
  NetworkRecipe? _selectedRecipe;
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _liveUpdates = [];

  final _updateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _wsService.stream.listen((message) {
      if (!mounted) return;
      setState(() {
        _liveUpdates.insert(0, message);
        if (_liveUpdates.length > 6) {
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

  Future<void> _runRequest(Future<NetworkResponse> Function() request) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await request();
      if (!mounted) return;
      setState(() {
        _response = response;
        if (response.recipes.isNotEmpty) {
          _selectedRecipe = response.recipes.first;
        }
      });
      _showSnackBar(
        '${response.method} ${response.path} -> ${response.statusCode}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showUpdateDialog() async {
    final selected = _selectedRecipe;
    if (selected == null) return;
    _updateController.text = selected.recipeTitle;

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('PATCH recipe title'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _updateController,
              decoration: const InputDecoration(labelText: 'New recipe title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Cannot be empty'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, _updateController.text.trim());
                }
              },
              child: const Text('Send PATCH'),
            ),
          ],
        );
      },
    );

    if (newTitle != null) {
      await _runRequest(
        () => _apiService.updateRecipePreview(selected, newTitle),
      );
    }
  }

  Future<void> _deletePreview() async {
    final selected = _selectedRecipe;
    if (selected == null) return;
    await _runRequest(() => _apiService.deleteRecipePreview(selected));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.leaf),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Networking & HTTP')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: StreamBuilder<List<SpaghettiDish>>(
          stream: _recipeService.watchRecipes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to fetch recipes: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final recipes = snapshot.data!;
            final catalog = recipes.map(NetworkRecipe.fromDish).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroPanel(
                        recipeCount: recipes.length,
                        selectedRecipe: _selectedRecipe,
                        isLoading: _isLoading,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: _errorMessage!),
                      ],
                      const SizedBox(height: 16),
                      _ActionRail(
                        isLoading: _isLoading,
                        hasSelection: _selectedRecipe != null,
                        onGet: recipes.isEmpty
                            ? null
                            : () => _runRequest(
                                () => _apiService.fetchRecipeCatalog(recipes),
                              ),
                        onPost: () =>
                            _runRequest(_apiService.createRecipePreview),
                        onPatch: _showUpdateDialog,
                        onDelete: _deletePreview,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 900;
                          final responsePanel = _ResponsePanel(
                            response: _response,
                          );
                          final catalogPanel = _CatalogPanel(
                            recipes: catalog,
                            selectedRecipe: _selectedRecipe,
                            onSelected: (recipe) {
                              setState(() => _selectedRecipe = recipe);
                            },
                          );
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: responsePanel),
                                const SizedBox(width: 16),
                                Expanded(flex: 4, child: catalogPanel),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              responsePanel,
                              const SizedBox(height: 16),
                              catalogPanel,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _LiveFeedPanel(
                        updates: _liveUpdates,
                        onConnect: _wsService.connect,
                        onDisconnect: _wsService.disconnect,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.recipeCount,
    required this.selectedRecipe,
    required this.isLoading,
  });

  final int recipeCount;
  final NetworkRecipe? selectedRecipe;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.highlightGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.berry.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.http, color: AppColors.strawberry, size: 42),
          ),
          SizedBox(
            width: 410,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recipe API Console',
                  style: TextStyle(
                    color: AppColors.berry,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use HTTP-style GET, POST, PATCH, and DELETE flows against the recipes already stored in this app.',
                  style: TextStyle(
                    color: AppColors.softInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _MetricPill(value: '$recipeCount', label: 'Firestore recipes'),
          _MetricPill(
            value: selectedRecipe?.recipeTitle ?? 'None',
            label: 'selected payload',
            wide: true,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.value,
    required this.label,
    this.wide = false,
  });

  final String value;
  final String label;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 220 : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.strawberry,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.softInk,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.isLoading,
    required this.hasSelection,
    required this.onGet,
    required this.onPost,
    required this.onPatch,
    required this.onDelete,
  });

  final bool isLoading;
  final bool hasSelection;
  final VoidCallback? onGet;
  final VoidCallback? onPost;
  final VoidCallback? onPatch;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.65)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: isLoading ? null : onGet,
            icon: const Icon(Icons.download),
            label: const Text('GET /recipes'),
          ),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onPost,
            icon: const Icon(Icons.add),
            label: const Text('POST preview'),
          ),
          OutlinedButton.icon(
            onPressed: isLoading || !hasSelection ? null : onPatch,
            icon: const Icon(Icons.edit),
            label: const Text('PATCH selected'),
          ),
          OutlinedButton.icon(
            onPressed: isLoading || !hasSelection ? null : onDelete,
            icon: const Icon(Icons.delete),
            label: const Text('DELETE preview'),
          ),
        ],
      ),
    );
  }
}

class _ResponsePanel extends StatelessWidget {
  const _ResponsePanel({required this.response});

  final NetworkResponse? response;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      icon: Icons.terminal,
      title: 'HTTP Response',
      child: Container(
        height: 420,
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2F2430),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SingleChildScrollView(
          child: Text(
            response?.prettyJson ??
                'Tap GET to fetch current Firestore recipes into an HTTP-style JSON response.',
            style: TextStyle(
              color: response == null ? AppColors.peach : AppColors.cream,
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogPanel extends StatelessWidget {
  const _CatalogPanel({
    required this.recipes,
    required this.selectedRecipe,
    required this.onSelected,
  });

  final List<NetworkRecipe> recipes;
  final NetworkRecipe? selectedRecipe;
  final ValueChanged<NetworkRecipe> onSelected;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      icon: Icons.restaurant_menu,
      title: 'Current Recipe Payloads',
      child: recipes.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No recipes found. Add or seed recipes first.'),
            )
          : Column(
              children: recipes.map((recipe) {
                final selected = selectedRecipe?.recipeId == recipe.recipeId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.peach.withValues(alpha: 0.62)
                        : AppColors.butter.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.strawberry : AppColors.line,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => onSelected(recipe),
                    leading: Icon(
                      recipe.vegetarian ? Icons.eco : Icons.ramen_dining,
                      color: recipe.vegetarian
                          ? AppColors.leaf
                          : AppColors.coral,
                    ),
                    title: Text(
                      recipe.recipeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.berry,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text('${recipe.category} • ${recipe.price}'),
                    trailing: selected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.strawberry,
                          )
                        : const Icon(Icons.chevron_right),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _LiveFeedPanel extends StatelessWidget {
  const _LiveFeedPanel({
    required this.updates,
    required this.onConnect,
    required this.onDisconnect,
  });

  final List<String> updates;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      icon: Icons.sensors,
      title: 'Live Recipe Stream',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onConnect,
                icon: const Icon(Icons.wifi),
                label: const Text('Connect stream'),
              ),
              OutlinedButton.icon(
                onPressed: onDisconnect,
                icon: const Icon(Icons.wifi_off),
                label: const Text('Disconnect'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 170,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2F2430),
              borderRadius: BorderRadius.circular(14),
            ),
            child: updates.isEmpty
                ? const Center(
                    child: Text(
                      'Connect to receive simulated recipe updates.',
                      style: TextStyle(color: AppColors.peach),
                    ),
                  )
                : ListView.builder(
                    itemCount: updates.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '> ${updates[index]}',
                          style: const TextStyle(
                            color: AppColors.mint,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.strawberry.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strawberry),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.berry,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.berry.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.peach.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.strawberry),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.berry,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
