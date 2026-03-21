# Specyfikacja systemu informatycznego - System zarządzania zadaniami zespołu (Task Manager)

## Lista części systemu
- REST API napisane w technologiach Django REST framework, MySQL
- aplikacja webowa napisana w technologiach Python, Django, Django templates  
- aplikacja mobilna napisana w technologiach Dart + Flutter
- aplikacja desktopowa napisana w technologiach C# + .NET

### Lista funkcjonalności

| OPZ | Funkcjonalność | API | web | mobile | desktop |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **SYS-01** | Użytkownik może założyć konto w systemie. | * | ✓ | ✓ | ✓ |
| **SYS-02** | Użytkownik może zalogować się do aplikacji. | * | ✓ | ✓ | ✓ |
| **SYS-03** | Użytkownik może tworzyć nowe zadania. | * | ✓ | ✓ | ✓ |
| **SYS-04** | Użytkownik może edytować i usuwać zadania. | * | ✓ | ✓ | ✓ |
| **SYS-05** | Użytkownik może przypisywać zadania do innych użytkowników. | * | ✓ | ✓ | ✓ |
| **SYS-06** | Użytkownik może zmieniać status zadania (np. do wykonania, w trakcie, zakończone). | * | ✓ | ✓ | ✓ |
| **SYS-07** | Użytkownik może przeglądać listę swoich zadań. | * | ✓ | ✓ | ✓ |
| **SYS-08** | Użytkownik może otrzymywać powiadomienia o zmianach w zadaniach. | * | ✓ | ✓ | ✓ |
| **SYS-09** | Użytkownik może zaakceptować zaproszenie do projektu od Administratora. | * | | ✓ | ✓ |
| **SYS-10** | Użytkownik może zarządzać swoim profilem i ustawieniami konta. | * | ✓ | ✓ | ✓ |
| **SYS-11** | Administrator może zarejestrować się i zalogować w systemie. | * | ✓ | | ✓ |
| **SYS-12** | Administrator może dodawać, edytować i usuwać zadania. | * | ✓ | | |
| **SYS-13** | Administrator może tworzyć nowe projekty. | * | ✓ | | ✓ |
| **SYS-14** | Administrator może edytować uprawnienia użytkowników przypisanych do projektu. | * | ✓ | | ✓ |
| **SYS-15** | Administrator może przydzielać użytkowników do konkretnych zadań. | * | ✓ | | ✓ |
| **SYS-16** | Administrator może monitorować aktywność użytkowników w systemie. | * | ✓ | | |
| **SYS-17** | Administrator może przeglądać logi bezpieczeństwa. | * | ✓ | | |
| **SYS-18** | Administrator otrzymuje powiadomienia, gdy użytkownik doda lub zmieni status zadania. | * | ✓ | | ✓ |
| **SYS-19** | Administrator może blokować konta po wykryciu podejrzanych działań. | * | ✓ | | |
| **SYS-20** | Administrator może filtrować zadania według przypisanego użytkownika. | * | ✓ | | ✓ |
| **SYS-21** | Administrator może usuwać projekty z systemu. | * | ✓ | | |
