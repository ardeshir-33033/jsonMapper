import 'package:dart_json_mapper/dart_json_mapper.dart' show DeserializationContext, DeserializationOptions, Json, JsonMapper, JsonMapperAdapter, JsonProperty, SerializationContext, SerializationOptions, jsonConstructor, jsonProperty, jsonSerializable;
import 'package:flutter/material.dart';
import 'main.mapper.g.dart' show initializeJsonMapper;



//////////////////////////////////////////////////////
/*
add this to your pubspec.yaml

dependencies:
  dart_json_mapper:
dev_dependencies:
  build_runner:

//////

put @jsonSerializable before any class which defines a model that needs to be mapped

//////

you have to create a build.yaml file at root of your project and fill it with this code
targets:
  $default:
    builders:
      dart_json_mapper:
          generate_for:
            - lib/main.dart

      # This part is needed to tell original reflectable builder to stay away
      # it overrides default options for reflectable builder to an **empty** set of files
      reflectable:
        generate_for:
          - no/files

////////
************************************

after this you MUST run this at your Terminal
flutter pub run build_runner build --delete-conflicting-outputs

this should generate main.mapper.g.dart and you must import it as it shown blew if this is not generated your program wont work

any time you want to change thing around you HAVE TO run this code   OR you can run this code
pub run build_runner watch --delete-conflicting-outputs

this code will detect changes in main function and rebuild main.mapper.g.dart

********
1. this code will work ONLY IF you change your main function so if you change your classes it would not work

2. after you change your main func and run the program this would not effect your program at first it would first run this code and if you run program the second time your desired changes would affect
*******

add this file to your .gitignore

and it is done!!!!!

************************************

*/
/////////////////////////////////////////////////////

// @jsonSerializable // This annotation let instances of MyData travel to/from JSON
// class TestData{
//   int b = 1;
//   String c = 'c';
//   bool bol = true;
//
//
//   TestData({this.b , this.bol , this.c});
// }
//

//


@jsonSerializable
class AllPrivateFields {
  String _name;
  String _lastName;

  set name(dynamic value) {
    _name = value;
  }

  String get name => _name;

  @JsonProperty(name: 'lastName')
  void setLastName(dynamic value) {
    _lastName = value;
  }

  @JsonProperty(name: 'lastName')
  String getLastName() => _lastName;

}



////////////////////////
@jsonSerializable
enum Color { Red, Blue, Green, Brown, Yellow, Black, White }

@jsonSerializable
class Car {
  @JsonProperty(name: 'modelName')
  String model;

  Color color;

  @JsonProperty(ignore: true)
  Car replacement;

  Car(this.model, this.color);
}
//////////////////////

@jsonSerializable // This annotation let instances of MyData travel to/from JSON
class MyData {
  @JsonProperty()
  int a = 123;

  @JsonProperty(name: 'b')
  bool b;

  @JsonProperty(name: 'd')
  String c;

  @JsonProperty(name: 'car')
  Car car;

  @JsonProperty(converterParams: {'format': 'MM-dd-yyyy H:m:s'})
  DateTime Date = DateTime(2008, 05, 13, 22, 33, 44);


  MyData(this.a, this.b, this.c , this.Date ,
     this.car
      );
}
//////////////////////
////abstract
@jsonSerializable
@Json(typeNameProperty: 'typeName')
abstract class Business {
  String name;
}

@jsonSerializable
class Hotel extends Business {
  int stars;

  Hotel(this.stars);
}

@jsonSerializable
class Startup extends Business {
  int userCount;

  Startup(this.userCount);
}

@jsonSerializable
class Stakeholder {
  String fullName;
  List<Business> businesses = [];

  Stakeholder(this.fullName, this.businesses);
}
//////////////////////
enum Scheme { A, B }

@jsonSerializable
@Json(name: 'default')
@Json(name: '_', scheme: Scheme.B)
@Json(name: 'root', scheme: Scheme.A)
class Object {
  @JsonProperty(name: 'title_test', scheme: Scheme.B)
  String title;

  Object(this.title);
}
//////////////////////
@jsonSerializable
abstract class ICustomConverter<T> {
  dynamic toJSON(T object, [SerializationContext context]);
  T fromJSON(dynamic jsonValue, [DeserializationContext context]);
}

@jsonSerializable
class CustomStringConverter implements ICustomConverter<String> {
  const CustomStringConverter() : super();

  @override
  String fromJSON(dynamic jsonValue, [DeserializationContext context]) {
    return jsonValue;
  }

  @override
  dynamic toJSON(String object, [SerializationContext context]) {
    return '_${object}_';
  }
}


main() {
  initializeJsonMapper();


  print(JsonMapper.serialize(MyData(456, true, "hellno" , DateTime(2008, 05, 13, 22, 33, 44) ,
      Car("Peykan", Color.Green)
  )));

  //
  // JsonMapper().useAdapter(JsonMapperAdapter(
  //     converters: {
  //       String: ICustomConverter();
  //     })
  // );


//////////////
  final jack = Stakeholder("Jack", [Startup(10), Hotel(4)]);
  final String json2 = JsonMapper.serialize(jack);
  final Stakeholder target = JsonMapper.deserialize(json2);
//////////////

  // print(
  //     JsonMapper.serialize(
  //         Immutable(1, 'Bob', Car('Audi', Color.Green))
  //     ));

/////
  final car = Car('Tesla S3', Color.Black);
  final cloneCar = JsonMapper.copyWith(car, {'color': Color.Blue});
//////

  final instance2 = Object('Scheme A');
  final json3 = JsonMapper.serialize(instance2, SerializationOptions(indent: '', scheme: Scheme.A));

  final instance3 = Object('Scheme B');
  final json4 = JsonMapper.serialize(instance3, SerializationOptions(indent: '', scheme: Scheme.B));


  final json5 = '''{"name":"Bob","lastName":"Marley"}''';
  final instance = JsonMapper.deserialize<AllPrivateFields>(json5);
  print("${instance.name} ${instance._lastName}");
  instance.name = "hello";
  print(instance.getLastName());

  final targetJson = JsonMapper.serialize(instance, SerializationOptions(indent: ''));



// then
  final json1 = targetJson;
  print(json1);


  instance.name = "BoB";
  instance.setLastName("Marley");

}









// const customConverter = CustomConverter();
//
// class CustomConverter implements ICustomConverter {
//   const CustomConverter();
//   @override
//   dynamic fromJSON(dynamic jsonValue, [DeserializationContext context]) {
//     return jsonValue + 1;
//   }
//
//   @override
//   dynamic toJSON(dynamic object, [SerializationContext context]) {
//     throw UnimplementedError();
//   }
// }
//
// @jsonSerializable
// class Record {
//   @JsonProperty(name: 'id')
//   int id;
//
//   int number;
//
//   @jsonConstructor
//   Record.json(this.id,
//       ////@JsonProperty(converter: customConverter)
//       @JsonProperty(converter: customConverter)
//       this.number);
//
//   @override
//   String toString() {
//     return '''{"id": $id, "number": $number}''';
//   }
// }



//
// var json8 = '''{"id": 42,  "number": 2}''';
//
// final target1 = JsonMapper.deserialize<Record>(
//     json8, DeserializationOptions(processAnnotatedMembersOnly: true));
