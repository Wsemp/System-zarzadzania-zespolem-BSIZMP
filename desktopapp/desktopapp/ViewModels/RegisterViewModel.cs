using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Services;
using System.Windows;
using System.Text.RegularExpressions;

namespace desktopapp.ViewModels
{
    public partial class RegisterViewModel : ObservableObject
    {
        [ObservableProperty] private string? _username;
        [ObservableProperty] private string? _email;
        [ObservableProperty] private string? _password;
        [ObservableProperty] private string? _confirmPassword;

        public Action? CloseAction { get; set; }

        private (bool IsValid, string ErrorMessage) ValidatePassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password)) return (false, "Hasło nie może być puste.");
            if (password.Length < 8) return (false, "Hasło musi mieć co najmniej 8 znaków.");


            if (!Regex.IsMatch(password, @"[a-z]")) return (false, "Hasło musi zawierać małą literę.");
            if (!Regex.IsMatch(password, @"[A-Z]")) return (false, "Hasło musi zawierać wielką literę.");
            if (!Regex.IsMatch(password, @"\d")) return (false, "Hasło musi zawierać cyfrę.");
            if (!Regex.IsMatch(password, @"[!@#$%^&*(),.?/|{}]")) return (false, "Hasło musi zawierać znak specjalny.");

            return (true, string.Empty);
        }

        [RelayCommand]
        public async Task RegisterAsync()
        {
            if (string.IsNullOrWhiteSpace(Username) || string.IsNullOrWhiteSpace(Email))
            {
                MessageBox.Show("Wypełnij wszystkie pola!", "Błąd walidacji");
                return;
            }

            var passwordCheck = ValidatePassword(Password ?? "");
            if (!passwordCheck.IsValid)
            {
                MessageBox.Show(passwordCheck.ErrorMessage, "Błąd bezpieczeństwa hasła");
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
                MessageBox.Show("Błąd podczas rejestracji! Użytkownik o takiej nazwie może już istnieć.",
                    "Błąd serwera");
            }
        }
    }
}