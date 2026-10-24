import '../../../domain/models/child.dart';
import '../kids_data_source.dart';

class DemoKidsDataSource implements KidsDataSource {
  const DemoKidsDataSource();

  static const _children = <Child>[
    Child(
      id: 'mateo-fernandez',
      firstName: 'Mateo',
      lastName: 'Fernández',
      ageYears: 3,
      linkedParents: 2,
      colorToken: 'blue',
      allergyLabel: 'MANÍ',
    ),
    Child(
      id: 'sofia-mendez',
      firstName: 'Sofía',
      lastName: 'Méndez',
      ageYears: 2,
      linkedParents: 1,
      colorToken: 'pink',
    ),
    Child(
      id: 'benjamin-ruiz',
      firstName: 'Benjamín',
      lastName: 'Ruiz',
      ageYears: 3,
      linkedParents: 2,
      colorToken: 'green',
    ),
    Child(
      id: 'valentina-soto',
      firstName: 'Valentina',
      lastName: 'Soto',
      ageYears: 2,
      linkedParents: 0,
      colorToken: 'yellow',
    ),
    Child(
      id: 'tomas-diaz',
      firstName: 'Tomás',
      lastName: 'Díaz',
      ageYears: 3,
      linkedParents: 1,
      colorToken: 'purple',
      allergyLabel: 'LACTOSA',
    ),
    Child(
      id: 'emma-castro',
      firstName: 'Emma',
      lastName: 'Castro',
      ageYears: 2,
      linkedParents: 1,
      colorToken: 'pink',
    ),
    Child(
      id: 'lucas-romero',
      firstName: 'Lucas',
      lastName: 'Romero',
      ageYears: 3,
      linkedParents: 1,
      colorToken: 'blue',
    ),
    Child(
      id: 'olivia-vega',
      firstName: 'Olivia',
      lastName: 'Vega',
      ageYears: 2,
      linkedParents: 1,
      colorToken: 'green',
    ),
  ];

  @override
  Future<List<Child>> fetchChildren() async => _children;
}
