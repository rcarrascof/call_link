import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/call_repository.dart';
import '../features/call/bloc/call_cubit.dart';
import '../features/call/views/call_screen.dart';
import '../core/themes/responsive_theme.dart';  

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => CallRepository(),
      child: BlocProvider(
        create: (context) => CallCubit(
          context.read<CallRepository>(),
        ),
        child: MaterialApp(
          title: 'Video Call App',
          theme: ResponsiveTheme.getTheme(context),  
          home: const SafeArea(  
            top: true,
            bottom: true,  
            left: true,
            right: true,
            child: CallScreen(),
          ),
        ),
      ),
    );
  }
}