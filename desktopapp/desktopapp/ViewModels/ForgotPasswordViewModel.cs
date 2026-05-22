using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Services;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;

namespace desktopapp.ViewModels
{
    public partial class ForgotPasswordViewModel : ObservableObject
    {
        [ObservableProperty]
        private string? _email;

        public Action? CloseAction { get; set; }

        [RelayCommand]
        public async Task ResetPasswordAsync()
        {
            if (string.IsNullOrWhiteSpace(Email))
            {
                MessageBox.Show("Podaj adres email!", "Błąd walidacji", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            
            if (!Regex.IsMatch(Email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                MessageBox.Show("Podaj poprawny format adresu email.", "Błąd walidacji", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            
            bool success = await ApiService.Instance.RequestPasswordResetAsync(Email);
            
            MessageBox.Show("Jeśli podany adres istnieje w systemie, wysłaliśmy na niego instrukcje resetu hasła.", 
                "Informacja", MessageBoxButton.OK, MessageBoxImage.Information);
            
            CloseAction?.Invoke();
        }
    }
}