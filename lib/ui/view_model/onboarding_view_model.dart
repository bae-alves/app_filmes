import 'package:flutter/foundation.dart';

import '../../data/models/user_onboarding_preferences.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../utils/result.dart';

class OnboardingPersonItem {
  const OnboardingPersonItem({
    required this.name,
    required this.imageUrl,
    this.knownFor,
  });

  final String name;
  final String imageUrl;
  final String? knownFor;
}

class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({
    required OnboardingRepository onboardingRepository,
    required String userId,
  }) : _onboardingRepository = onboardingRepository,
       _userId = userId;

  final OnboardingRepository _onboardingRepository;
  final String _userId;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  final Set<String> _selectedGenres = {};
  Set<String> get selectedGenres => Set.unmodifiable(_selectedGenres);

  final Set<String> _selectedActors = {};
  Set<String> get selectedActors => Set.unmodifiable(_selectedActors);

  final Set<String> _selectedDirectors = {};
  Set<String> get selectedDirectors => Set.unmodifiable(_selectedDirectors);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  static const popularGenres = [
    'Ação',
    'Comédia',
    'Animação',
    'Drama',
    'Ficção Científica',
    'Terror',
    'Romance',
    'Suspense',
    'Aventura',
    'Fantasia',
    'Crime',
    'Família',
  ];

  static const popularActors = [
    OnboardingPersonItem(
      name: 'Keanu Reeves',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
      knownFor: 'John Wick, Matrix',
    ),
    OnboardingPersonItem(
      name: 'Leonardo DiCaprio',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      knownFor: 'A Origem, Titanic',
    ),
    OnboardingPersonItem(
      name: 'Zendaya',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Duna, Homem-Aranha',
    ),
    OnboardingPersonItem(
      name: 'Margot Robbie',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Barbie, Esquadrão Suicida',
    ),
    OnboardingPersonItem(
      name: 'Tom Cruise',
      imageUrl:
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Top Gun, Missão Impossível',
    ),
    OnboardingPersonItem(
      name: 'Scarlett Johansson',
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Vingadores, História de um Casamento',
    ),
    OnboardingPersonItem(
      name: 'Cillian Murphy',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Oppenheimer, Peaky Blinders',
    ),
    OnboardingPersonItem(
      name: 'Viola Davis',
      imageUrl:
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=300&q=80',
      knownFor: 'A Mulher Rei, Histórias Cruzadas',
    ),
  ];

  static const popularDirectors = [
    OnboardingPersonItem(
      name: 'Christopher Nolan',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Oppenheimer, Batman',
    ),
    OnboardingPersonItem(
      name: 'Steven Spielberg',
      imageUrl:
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Jurassic Park, E.T.',
    ),
    OnboardingPersonItem(
      name: 'Quentin Tarantino',
      imageUrl:
          'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Pulp Fiction, Django Livre',
    ),
    OnboardingPersonItem(
      name: 'Denis Villeneuve',
      imageUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Duna, Blade Runner 2049',
    ),
    OnboardingPersonItem(
      name: 'Greta Gerwig',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=300&q=80',
      knownFor: 'Barbie, Adoráveis Mulheres',
    ),
    OnboardingPersonItem(
      name: 'Guillermo del Toro',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
      knownFor: 'A Forma da Água, Pinóquio',
    ),
  ];

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    final res = await _onboardingRepository.getPreferences(_userId);
    if (res case Ok(:final value)) {
      _selectedGenres.clear();
      _selectedGenres.addAll(value.genres);

      _selectedActors.clear();
      _selectedActors.addAll(value.actors);

      _selectedDirectors.clear();
      _selectedDirectors.addAll(value.directors);
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void toggleActor(String actorName) {
    if (_selectedActors.contains(actorName)) {
      _selectedActors.remove(actorName);
    } else {
      _selectedActors.add(actorName);
    }
    notifyListeners();
  }

  void toggleDirector(String directorName) {
    if (_selectedDirectors.contains(directorName)) {
      _selectedDirectors.remove(directorName);
    } else {
      _selectedDirectors.add(directorName);
    }
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<bool> saveAndComplete() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final prefs = UserOnboardingPreferences(
      userId: _userId,
      genres: _selectedGenres.toList(),
      actors: _selectedActors.toList(),
      directors: _selectedDirectors.toList(),
      isCompleted: true,
    );

    final res = await _onboardingRepository.savePreferences(prefs);

    _isLoading = false;
    var success = false;

    switch (res) {
      case Ok():
        success = true;
      case Error(:final error):
        _errorMessage = error.toString();
    }

    notifyListeners();
    return success;
  }
}
