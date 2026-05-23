using desktopapp.ViewModels;
using Xunit;

namespace desktopapp.Tests
{
    public class PasswordsEmailTests
    {
        [Theory]
        // 1. Puste hasła i spacje
        [InlineData(null, false, "Hasło nie może być puste.")]
        [InlineData("", false, "Hasło nie może być puste.")]
        [InlineData("   ", false, "Hasło nie może być puste.")]
        
        // 2. Za krótkie hasło (ma 7 znaków)
        [InlineData("Krotki1", false, "Hasło musi mieć co najmniej 8 znaków.")]
        
        // 3. Brak małej litery
        [InlineData("TYLKODUZE1!", false, "Hasło musi zawierać małą literę.")]
        
        // 4. Brak wielkiej litery
        [InlineData("tylkomale1!", false, "Hasło musi zawierać wielką literę.")]
        
        // 5. Brak cyfry
        [InlineData("BrakCyfry!", false, "Hasło musi zawierać cyfrę.")]
        
        // 6. Brak znaku specjalnego
        [InlineData("BrakZnaku123", false, "Hasło musi zawierać znak specjalny.")]
        
        // 7. Poprawne silne hasła (spełniające wszystkie wymogi BSI)
        [InlineData("SilneHaslo123!", true, "")]
        [InlineData("InneSuperHaslo9@", true, "")]
        [InlineData("ToJestBardzoDlugieHasloKtoreMaPonadStoDwadziesciaOsiemZnakow_i_ZarazWywaliNamAplikacjeBoKtosWkleilTutajCalaKsiazke123!@#_DODAJEMY_JESZCZE_WIECEJ_LITER_ZEBY_PRZEBIC_LIMIT", false, "Hasło jest zbyt długie (max 128 znaków).")]
        public void ValidatePassword_ShouldEnforcePasswordPolicy(string password, bool expectedIsValid, string expectedErrorMessage)
        {
            // Arrange - Przygotowanie obiektu
            var viewModel = new RegisterViewModel();

            // Act - Wywołanie metody walidującej
            var result = viewModel.ValidatePassword(password);

            // Assert - Sprawdzenie, czy wynik jest zgodny z oczekiwaniami
            Assert.Equal(expectedIsValid, result.IsValid);
            Assert.Equal(expectedErrorMessage, result.ErrorMessage);
        }
        
        [Theory]
        // 1. Zwykłe pomyłki i błędne formaty
        [InlineData(null, false)]
        [InlineData("", false)]
        [InlineData("   ", false)]
        [InlineData("brak_malpy.com", false)]
        [InlineData("test@.com", false)]
        [InlineData("@domena.pl", false)]
        [InlineData("test@domena", false)] // brak końcówki .pl/.com
        
        // 2. Próby ataków (Złośliwe payloady - Security Tests)
        [InlineData("<script>alert(1)</script>@gmail.com", false)] // Atak XSS (Cross-Site Scripting)
        [InlineData("admin' OR '1'='1@gmail.com", false)]           // Atak SQL Injection
        [InlineData("test@gmail.com\n\r", false)]                  // Atak CRLF Injection (wstrzykiwanie nagłówków)
        [InlineData("test @gmail.com", false)]                     // Spacja wewnątrz maila
        
        // 3. Właściwe, poprawne adresy email
        [InlineData("poprawny.email@gmail.com", true)]
        [InlineData("jan.kowalski123@firma.com.pl", true)]
        public void ValidateEmail_Powinno_Blokowac_Bledne_Oraz_Zlosliwe_Adresy(string email, bool expectedIsValid)
        {
            // Arrange - Przygotowanie instancji ViewModelu
            var viewModel = new RegisterViewModel();

            // Act - Wywołanie metody walidującej email
            var result = viewModel.ValidateEmail(email);

            // Assert - Sprawdzenie czy nasza funkcja zwróciła oczekiwany wynik
            Assert.Equal(expectedIsValid, result);
        }
    }
}