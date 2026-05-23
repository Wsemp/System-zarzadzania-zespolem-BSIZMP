using desktopapp.ViewModels;
using Xunit;

namespace desktopapp.Tests
{
    public class PasswordsTests
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
    }
}