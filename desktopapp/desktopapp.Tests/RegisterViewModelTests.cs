using desktopapp.ViewModels;
using Xunit;

namespace desktopapp.Tests
{
    public class RegisterViewModelTests
    {
        [Fact]
        public void Rejestracja_Niemozliwa_Gdy_Hasla_Sie_Roznia()
        {
            var viewModel = new RegisterViewModel();
            viewModel.Username = "testuser";
            viewModel.Email = "test@test.com";
            viewModel.Password = "Haslo123!";
            viewModel.ConfirmPassword = "InneHaslo123!";

        }
    }
    
    
}