// frontend/lib/widgets/paginated_list.dart
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

/// Widget genérico de paginação client-side.
/// Passa a lista completa e ele fatia por página.
class PaginatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int pageSize;
  final Widget? empty;

  const PaginatedList({
    required this.items,
    required this.itemBuilder,
    this.pageSize = 15,
    this.empty,
    super.key,
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  int _page = 0;

  @override
  void didUpdateWidget(PaginatedList<T> old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.empty ??
          const Center(
            child: Text(
              'Nenhum item encontrado.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
    }

    final totalPages = (widget.items.length / widget.pageSize).ceil();
    final start = _page * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, widget.items.length);
    final pageItems = widget.items.sublist(start, end);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: pageItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (ctx, i) =>
                widget.itemBuilder(ctx, pageItems[i], start + i),
          ),
        ),
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page == 0 ? null : () => setState(() => _page--),
                ),
                Text(
                  '${_page + 1} / $totalPages',
                  style: const TextStyle(fontSize: 13),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _page == totalPages - 1
                      ? null
                      : () => setState(() => _page++),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
