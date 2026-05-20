using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Services;
using System.Windows;

namespace desktopapp.ViewModels
{
    public partial class RegisterViewModel : ObservableObject
    {
        [ObservableProperty] private string? _username;
        [ObservableProperty] private string? _email;
        [ObservableProperty] private string? _password;
        [ObservableProperty] private string? _confirmPassword;

        public Action? CloseAction { get; set; }

        [RelayCommand]
        public async Task RegisterAsync()
        {
            if (string.IsNullOrWhiteSpace(Username) || string.IsNullOrWhiteSpace(Password) || string.IsNullOrWhiteSpace(Email))
            {
                MessageBox.Show("Wypełnij wszystkie pola!", "Błąd walidacji");
                return;
            }

            if (Password != ConfirmPassword)
            {
                MessageBox.Show("Podane hasła nie są identyczne!", "Błąd walidacji");
                return;
            }

            bool isSuccess = await ApiService.Instance.RegisterAsync(Username!, Email!, Password!);

            if (isSuccess)
            {
                MessageBox.Show("Konto zostało pomyślnie utworzone! Możesz się zalogować.", "Sukces");
                CloseAction?.Invoke();
            }
            else
            {
                MessageBox.Show("Błąd podczas rejestracji! Użytkownik o takiej nazwie może już istnieć.", "Błąd serwera");
            }
        }
    }
}