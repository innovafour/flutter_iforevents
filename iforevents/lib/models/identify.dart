import 'package:equatable/equatable.dart';

class IdentifyEvent extends Equatable {
  const IdentifyEvent({required this.customID, required this.properties});

  final String customID;
  final Map<String, dynamic> properties;

  IdentifyEvent copyWith({String? customID, Map<String, dynamic>? properties}) {
    return IdentifyEvent(
      customID: customID ?? this.customID,
      properties: properties ?? this.properties,
    );
  }

  @override
  List<Object?> get props => [customID, properties];
}
