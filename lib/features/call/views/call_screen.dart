import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call_cubit.dart';
import '../bloc/call_state.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/video_views_widget.dart';
import '../widgets/call_controls_widget.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CallCubit, CallState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ConnectionStatusWidget(state: state),
                const SizedBox(height: 20),
                Expanded(
                  child: VideoViewsWidget(state: state),
                ),
                const SizedBox(height: 20),
                CallControlsWidget(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}