import 'package:flutter/material.dart';

class LoaderFeedbackCow extends StatefulWidget {
  const LoaderFeedbackCow({super.key, this.mensagem, this.size});
  final String? mensagem;
  final double? size;

  @override
  State<LoaderFeedbackCow> createState() => _LoaderFeedbackCowState();
}

class _LoaderFeedbackCowState extends State<LoaderFeedbackCow> {
  @override
  Widget build(BuildContext context) {
    if (widget.size! < 50) {
      return Padding(
        padding: const EdgeInsets.all(9.0),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                "assets/gifs/cowMove.gif",
                fit: BoxFit.contain,
                height: widget.size,
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              if (!(widget.mensagem == "" || widget.mensagem == null)) Text(widget.mensagem!),
              Image.asset(
                "assets/gifs/cowMove.gif",
                fit: BoxFit.contain,
                height: widget.size,
                alignment: Alignment.center,
              )
            ],
          ),
        ),
      );
    }
  }
}
