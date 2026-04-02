import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class ChartData {
  final String label;
  final double value;
  final Color color;

  const ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class HorizontalBarChart extends StatelessWidget {
  final List<ChartData> data;
  final String? titulo;
  final double maxValue;

  const HorizontalBarChart({
    required this.data,
    this.titulo,
    this.maxValue = 0, // 0 = calcula automaticamente
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final max = maxValue > 0
        ? maxValue
        : data.map((d) => d.value).reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null) ...[
          Text(
            titulo!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...data.map((item) {
          final pct = max > 0 ? (item.value / max).clamp(0.0, 1.0) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.value % 1 == 0
                          ? item.value.toInt().toString()
                          : item.value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: pct),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (_, value, __) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: item.color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(item.color),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class DonutChart extends StatelessWidget {
  final List<ChartData> data;
  final String? centerLabel;
  final String? centerValue;
  final double size;

  const DonutChart({
    required this.data,
    this.centerLabel,
    this.centerValue,
    this.size = 140,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final total = data.fold(0.0, (s, d) => s + d.value);
    if (total == 0) return const SizedBox();

    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (_, progress, __) => SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _DonutPainter(
                data: data,
                total: total,
                progress: progress,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (centerValue != null)
                      Text(
                        centerValue!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    if (centerLabel != null)
                      Text(
                        centerLabel!,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              final pct = (item.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ChartData> data;
  final double total;
  final double progress; // 0.0 → 1.0 para animação

  _DonutPainter({
    required this.data,
    required this.total,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.18;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    paint.color = Colors.grey.shade200;
    canvas.drawCircle(center, radius - strokeWidth / 2, paint);

    double startAngle = -math.pi / 2;

    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi * progress;
      paint.color = item.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}

class KpiCard extends StatelessWidget {
  final String valor;
  final String label;
  final IconData icon;
  final Color color;
  final String? subtitulo;

  const KpiCard({
    required this.valor,
    required this.label,
    required this.icon,
    required this.color,
    this.subtitulo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              valor,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
