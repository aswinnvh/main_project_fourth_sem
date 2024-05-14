import 'package:equatable/equatable.dart';

class Response extends Equatable{

  final String? statusMessage;
  final int? statusCode;
  final bool? success;

  const Response({required this.statusCode, required this.statusMessage, required this.success});

  @override
  List<Object?> get props => [statusCode, statusMessage, success];
}


// Class Definition:
//
// class Response extends Equatable : This declares a class named Response that inherits from the Equatable class.

// Properties:
//
// final String? statusMessage;: This property stores the status message of the response as a nullable String. The question mark (?) indicates that it can be null.
// final int? statusCode;: This property stores the status code of the response as a nullable integer.
// final bool? success;: This property stores a boolean value indicating whether the response was successful. It's also nullable.

// Constructor:
//
// const Response({required this.statusCode, required this.statusMessage, required this.success});: This is the constructor for the Response class. It takes three required arguments:
// statusCode: The status code of the response.
// statusMessage: The status message of the response.
// success: A boolean indicating whether the response was successful.


// @override List<Object?> get props => [statusCode, statusMessage, success];:
// This line overrides the props getter from the Equatable mixin. It returns a list of the properties that should be used for equality comparisons. In this case, all three properties (statusCode, statusMessage, and success) are used to determine if two Response objects are equal.



// Overall, this code snippet effectively defines a class to represent API responses with relevant properties and uses the Equatable package for easier equality checks.