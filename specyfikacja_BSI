# Specyfikacja projektowa – Bezpieczeństwo systemów informatycznych  
## System zarządzania zadaniami zespołu (Task Manager)

---

## Wybrany temat projektu
Zabezpieczenie wieloplatformowego systemu Task Manager poprzez implementację bezpiecznego uwierzytelniania, autoryzacji oraz ochrony dostępu do zasobów systemu.

---

## Skład grupy projektowej

| Osoba   | Odpowiedzialność |
| :------- | :---------------- |
| Daniel Kozak | aplikacja webowa (Django, integracja bezpieczeństwa) |
| Wiktor Semp | aplikacja desktopowa (C# + .NET, obsługa uwierzytelniania) |
| Emilia Małecka | aplikacja mobilna (Flutter, 2FA i bezpieczeństwo mobilne) |

---

## Opis problemu

System Task Manager jest aplikacją wieloplatformową (web, mobile, desktop), w której użytkownicy zarządzają zadaniami i projektami. Dostęp do systemu odbywa się przez REST API, co wprowadza ryzyko związane z bezpieczeństwem.

### Główne problemy bezpieczeństwa:
- nieautoryzowany dostęp do kont użytkowników  
- przejęcie sesji lub tokenów  
- ataki brute-force  
- brak dodatkowej weryfikacji użytkownika (2FA)  
- niespójne zabezpieczenia między platformami  

---

## Sposób realizacji

Projekt zakłada wdrożenie mechanizmów zabezpieczających dostęp do systemu:

### Mechanizmy bezpieczeństwa
- [x] rejestracja i logowanie użytkowników  
- [x] bezpieczne przechowywanie haseł (hashowanie)  
- [x] reset hasła z użyciem tokenów jednorazowych  
- [x] logowanie przez Google (OAuth 2.0)  
- [x] weryfikacja dwuetapowa (2FA)  
- [x] kontrola dostępu na podstawie ról  
- [x] zabezpieczenie komunikacji (HTTPS)  

### Architektura
- REST API jako centralny punkt uwierzytelniania  
- trzy niezależne klienty korzystające z API:
  - web
  - mobile
  - desktop  

---

## Podstawowe cele i zadania

### Cele
- zapewnienie bezpiecznego dostępu do systemu  
- ochrona danych użytkowników  
- wdrożenie nowoczesnych metod uwierzytelniania  
- ujednolicenie bezpieczeństwa na wszystkich platformach  

### Zadania
- [ ] implementacja systemu logowania i rejestracji  
- [ ] wdrożenie OAuth 2.0 (Google)  
- [ ] implementacja 2FA  
- [ ] zabezpieczenie komunikacji klient–API  
- [ ] testowanie mechanizmów bezpieczeństwa  

---

## Technologie i narzędzia

### Backend
| Technologia | Zastosowanie |
| :----------- | :------------ |
| Django REST Framework | REST API |
| MySQL | baza danych |

### Frontend
| Platforma | Technologia |
| :--------- | :----------- |
| Web | Django Templates |
| Mobile | Flutter (Dart) |
| Desktop | C# + .NET |

### Bezpieczeństwo
- JWT / token-based authentication  
- OAuth 2.0 (Google Sign-In)  
- 2FA (TOTP)  
- HTTPS (TLS)  
- hashowanie haseł (bcrypt / PBKDF2)  

---

## Repozytorium GIT
