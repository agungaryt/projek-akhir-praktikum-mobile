// ============================================
// TimurLang - Mountain List Screen
// Modul V (HTTP Request/REST API) & Modul VIII (GetX State Management)
// Preserving Original Aura Travel Design System & Plus Jakarta Sans Font
// ============================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../controllers/mountain_controller.dart';
import '../../widgets/mountain_card.dart';

class MountainListScreen extends StatefulWidget {
  final bool embedded;
  const MountainListScreen({super.key, this.embedded = false});

  @override
  State<MountainListScreen> createState() => _MountainListScreenState();
}

class _MountainListScreenState extends State<MountainListScreen> {
  final MountainController controller = Get.find<MountainController>();
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  String? _selectedGrade;
  bool? _sumberAir;
  RangeValues _elevasiRange = const RangeValues(0, 5000);

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyLocalFilters() {
    controller.filterMountainsWithCriteria(
      search: _searchCtrl.text.trim(),
      grade: _selectedGrade,
      sumberAir: _sumberAir,
      minElevasi: _elevasiRange.start.round(),
      maxElevasi: _elevasiRange.end.round(),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _selectedGrade = null;
      _sumberAir = null;
      _elevasiRange = const RangeValues(0, 5000);
    });
    controller.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = _selectedGrade != null ||
        _sumberAir != null ||
        _elevasiRange.start > 0 ||
        _elevasiRange.end < 5000 ||
        _searchCtrl.text.isNotEmpty;

    final content = CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (!widget.embedded)
          SliverAppBar(
            title: Text(
              'Cari Gunung',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            floating: true,
            snap: true,
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, widget.embedded ? 16 : 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.embedded) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Jelajahi Gunung',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Search Bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _applyLocalFilters(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surface,
                    hintText: 'Cari nama gunung...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 13.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.border, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.border, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.primary),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _showFilters = !_showFilters),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _showFilters
                              ? AppTheme.primary.withValues(alpha: 0.15)
                              : AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _showFilters
                                ? AppTheme.primary.withValues(alpha: 0.3)
                                : AppTheme.border,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: _showFilters ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Filters
                if (_showFilters) ...[
                  const SizedBox(height: 14),
                  _buildFilters(),
                ],
                const SizedBox(height: 14),

                // Results count & reset
                Obx(() {
                  final count = controller.filteredMountains.length;
                  return Row(
                    children: [
                      Text(
                        '$count gunung ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (hasActiveFilter)
                        GestureDetector(
                          onTap: _resetFilters,
                          child: Text(
                            'Reset Filter',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Mountain List Content (Reactive GetX)
        Obx(() {
          if (controller.isLoading.value) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }

          final list = controller.filteredMountains;
          if (list.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.terrain_rounded,
                      size: 64,
                      color: AppTheme.textSecondary.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Gunung tidak ditemukan',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final mountain = list[i];
                  return MountainCard(
                    mountain: mountain,
                    onTap: () => Get.toNamed(
                      AppRoutes.mountainDetail,
                      arguments: mountain,
                    ),
                  );
                },
                childCount: list.length,
              ),
            ),
          );
        }),

        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );

    final wrappedContent = RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => controller.fetchMountains(),
      child: content,
    );

    if (widget.embedded) {
      return SafeArea(child: wrappedContent);
    }

    return Scaffold(body: SafeArea(child: wrappedContent));
  }

  Widget _buildFilters() {
    final hasActiveFilter = _selectedGrade != null ||
        _sumberAir != null ||
        _elevasiRange.start > 0 ||
        _elevasiRange.end < 5000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Header
          Row(
            children: [
              const Icon(Icons.filter_list_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filter Pencarian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (hasActiveFilter)
                InkWell(
                  onTap: _resetFilters,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Elevation Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rentang Elevasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${_elevasiRange.start.round()} - ${_elevasiRange.end.round()} mdpl',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.surfaceSubtle,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: _elevasiRange,
              min: 0,
              max: 5000,
              divisions: 50,
              onChanged: (v) {
                setState(() => _elevasiRange = v);
                _applyLocalFilters();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 mdpl',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                ),
                Text(
                  '5.000 mdpl',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tingkat Bahaya (Grade)
          Text(
            'Tingkat Kesulitan / Bahaya',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.mountainGrades.map((grade) {
              final label = grade.split(' - ').first;
              final isSelected = _selectedGrade == grade;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() => _selectedGrade = isSelected ? null : grade);
                  _applyLocalFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: 1.1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Sumber Air
          Text(
            'Ketersediaan Sumber Air',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildWaterFilterOption(
                label: 'Semua',
                isSelected: _sumberAir == null,
                icon: Icons.all_inclusive_rounded,
                onTap: () {
                  setState(() => _sumberAir = null);
                  _applyLocalFilters();
                },
              ),
              const SizedBox(width: 8),
              _buildWaterFilterOption(
                label: 'Air',
                isSelected: _sumberAir == true,
                icon: Icons.water_drop_outlined,
                onTap: () {
                  setState(() => _sumberAir = _sumberAir == true ? null : true);
                  _applyLocalFilters();
                },
              ),
              const SizedBox(width: 8),
              _buildWaterFilterOption(
                label: 'Tidak Ada Air',
                isSelected: _sumberAir == false,
                icon: Icons.water_drop_outlined,
                onTap: () {
                  setState(() => _sumberAir = _sumberAir == false ? null : false);
                  _applyLocalFilters();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterFilterOption({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border,
              width: 1.1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
