import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ims_scanner_app/common/widget/reusable_appbar/appbar.dart';
import 'package:ims_scanner_app/features/authentication/data/local/auth_session_storage.dart';
import 'package:ims_scanner_app/features/authentication/data/local/branch_selection_storage.dart';
import 'package:ims_scanner_app/features/authentication/data/repositories/branches_repository.dart';
import 'package:ims_scanner_app/features/authentication/domain/models/branch_option.dart';
import 'package:ims_scanner_app/features/authentication/presentation/providers/auth_controller.dart';
import 'package:ims_scanner_app/routers/app_route_paths.dart';
import 'package:ims_scanner_app/utils/constants/sizes.dart'; 
class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  final BranchesRepository _branchesRepository = BranchesRepository();
  List<BranchOption> _branches = <BranchOption>[];
  String? _selectedBranchKey;
  bool _isLoadingBranches = true;
  bool _isLoggingOut = false;
  String? _errorMessage;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoadingBranches = true;
      _errorMessage = null;
    });

    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.userId ?? await AuthSessionStorage.readUserId();

      final branches = await _branchesRepository.fetchBranches(userId);
      final Map<String, BranchOption> uniqueBranchMap = <String, BranchOption>{};
      for (final branch in branches) {
        uniqueBranchMap[_branchKey(branch)] = branch;
      }
      final dedupedBranches = uniqueBranchMap.values.toList();
      final savedSelection = await BranchSelectionStorage.readSelectedBranch();

      BranchOption? selected;
      if (savedSelection != null) {
        for (final item in dedupedBranches) {
          if (item.companyCode == savedSelection.companyCode &&
              item.branchCode == savedSelection.branchCode) {
            selected = item; // use exact instance from item list
            break;
          }
        }
      }

      if (selected == null && dedupedBranches.isNotEmpty) {
        selected = dedupedBranches.first;
        await BranchSelectionStorage.saveSelectedBranch(selected);
      }

      if (!mounted) return;
      setState(() {
        _branches = dedupedBranches;
        _selectedBranchKey = selected != null ? _branchKey(selected) : null;
        _userId = userId;
        _isLoadingBranches = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBranches = false;
        _errorMessage = 'Failed to load branches. ${e.toString()}';
      });
    }
  }

  Future<void> _onSelectBranch(String? branchKey) async {
    if (branchKey == null) return;

    BranchOption? value;
    for (final item in _branches) {
      if (_branchKey(item) == branchKey) {
        value = item;
        break;
      }
    }
    if (value == null) return;

    setState(() {
      _selectedBranchKey = branchKey;
    });

    await BranchSelectionStorage.saveSelectedBranch(value);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Branch selected: ${value.companyCode}/${value.branchCode}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _branchKey(BranchOption branch) {
    return '${branch.companyCode}|${branch.branchCode}';
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    await ref.read(authControllerProvider.notifier).signOut();

    if (!mounted) return;
    setState(() {
      _isLoggingOut = false;
    });
    context.go(AppRoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final validKeys = _branches.map(_branchKey).toSet();
    final dropdownValue = (_selectedBranchKey != null && validKeys.contains(_selectedBranchKey))
        ? _selectedBranchKey
        : null;

    return Scaffold(
      appBar: AppReusableAppBar(
        title: Text('Settings'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((auth.userId ?? _userId) != null)
                Text('User: ${auth.user?.name.isNotEmpty == true ? auth.user!.name : auth.userId ?? _userId}'),
              if (auth.user?.email.isNotEmpty == true)
                Text(
                  auth.user!.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),
              const Text(
                'Branch',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_isLoadingBranches)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadBranches,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: dropdownValue,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select Branch',
                  ),
                  selectedItemBuilder: (context) {
                    return _branches.map((branch) {
                      return Text(
                        '[${branch.companyCode}] ${branch.branchCode}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }).toList();
                  },
                  items: _branches.map((branch) {
                    return DropdownMenuItem<String>(
                      value: _branchKey(branch),
                      child: Text(
                        '[${branch.companyCode}] ${branch.label}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: _onSelectBranch,
                ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoggingOut ? null : _logout,
                  child: Text(_isLoggingOut ? 'Signing out...' : 'Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
