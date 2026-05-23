import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core.dart';

class VoiceSearchDialog extends StatefulWidget {
  final Function(String) onResult;

  const VoiceSearchDialog({
    super.key,
    required this.onResult,
  });

  @override
  State<VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<VoiceSearchDialog>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  String _status = 'Listening...';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _initializeAndStartListening();
  }

  Future<void> _initializeAndStartListening() async {
    // Initialize speech recognition
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            _animationController.stop();
            _animationController.reset();
            if (_text.isNotEmpty) {
              _status = 'Searching...';
              // Store the text before closing
              final searchText = _text;
              // Close dialog and call callback
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
                // Call callback after dialog is closed
                widget.onResult(searchText);
              });
            } else {
              _status = 'No speech detected. Try again.';
            }
          }
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _animationController.stop();
          _animationController.reset();
          _status = 'Error: ${error.errorMsg}';
        });
      },
    );

    if (!available) {
      if (mounted) {
        setState(() {
          _status = 'Speech recognition not available';
        });
      }
      return;
    }

    _isInitialized = true;
    
    // Start listening immediately after initialization
    if (mounted) {
      _startListening();
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      if (!_isInitialized) {
        await _initializeAndStartListening();
      } else {
        _startListening();
      }
    }
  }

  void _startListening() {
    if (!mounted) return;
    
    setState(() {
      _isListening = true;
      _text = '';
      _status = 'Listening...';
      _animationController.repeat(reverse: true);
    });

    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _text = result.recognizedWords;
          if (result.finalResult) {
            _status = 'Processing...';
             if (mounted) {
              Navigator.of(context).pop(); 
            }
            widget.onResult(_text);
          }
        });
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _animationController.stop();
        _animationController.reset();
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.kPrimaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voice Search',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _scaleAnimation.value : 1.0,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? AppColors.kPrimaryColor
                            : AppColors.kPrimaryColor.withValues(alpha: 0.3),
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: AppColors.kPrimaryColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 50.sp,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            if (_text.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.kNeutral90Color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    _stopListening();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                if (_isListening)
                  TextButton(
                    onPressed: _stopListening,
                    child: Text(
                      'Stop',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

