import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/widgets/entries/entry_card_content_widget.dart';
import 'package:travel_journal/features/entry_detail/entry_detail_screen.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/shared/models/journal_entry_model.dart';

class SwipeToDeleteCardWidget extends StatefulWidget {
  const SwipeToDeleteCardWidget({super.key, required this.entry});

  final JournalEntryModel entry;

  @override
  State<SwipeToDeleteCardWidget> createState() =>
      _SwipeToDeleteCardWidgetState();
}

class _SwipeToDeleteCardWidgetState extends State<SwipeToDeleteCardWidget>
    with TickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isDragging = false;

  static const double _deleteThreshold = 120;
  static const double _wobbleThreshold = 20;

  late final AnimationController _wobbleController;
  late final Animation<double> _wobbleAnimation;

  late final AnimationController _snapController;
  late final Animation<double> _snapAnimation;

  double _snapFrom = 0;

  bool _deleted = false;

  @override
  void initState() {
    super.initState();

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _wobbleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
        );

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapAnimation = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOut,
    );
    _snapAnimation.addListener(() {
      setState(() {
        _dragOffset = _snapFrom * (1 - _snapAnimation.value);
      });
    });
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_deleted) return;
    setState(() {
      _dragOffset += details.delta.dx;
      _isDragging = true;
    });

    if (_dragOffset.abs() > _wobbleThreshold &&
        !_wobbleController.isAnimating) {
      _wobbleController.forward(from: 0);
      HapticFeedback.lightImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_deleted) return;
    _isDragging = false;

    if (_dragOffset.abs() >= _deleteThreshold) {
      _commitDelete();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    _snapFrom = _dragOffset;
    _snapController.forward(from: 0);
  }

  void _commitDelete() async {
    final flyTarget = _dragOffset > 0
        ? MediaQuery.of(context).size.width
        : -MediaQuery.of(context).size.width;

    HapticFeedback.mediumImpact();

    _snapFrom = _dragOffset - flyTarget;
    await _animateTo(flyTarget);

    if (!mounted) return;
    setState(() => _deleted = true);

    context.read<JournalStore>().removeEntry(widget.entry.entryId);
  }

  Future<void> _animateTo(double target) async {
    final start = _dragOffset;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    final anim = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    anim.addListener(() {
      if (mounted) {
        setState(() => _dragOffset = start + (target - start) * anim.value);
      }
    });
    await controller.forward();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) return const SizedBox.shrink();

    final swipingLeft = _dragOffset < 0;
    final progress = (_dragOffset.abs() / _deleteThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: progress,
              duration: Duration.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: swipingLeft
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 28,
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _wobbleAnimation,
            builder: (context, child) {
              final rotateDeg = _isDragging ? _wobbleAnimation.value : 0.0;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(_dragOffset, 0)
                  ..rotateZ(rotateDeg * 3.14159 / 180),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EntryDetailScreen(entry: widget.entry),
                  ),
                );
              },
              child: EntryCardContent(entry: widget.entry),
            ),
          ),
        ],
      ),
    );
  }
}
