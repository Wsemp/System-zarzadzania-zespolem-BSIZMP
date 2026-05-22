using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Services;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;

namespace desktopapp.ViewModels
{
    public partial class InviteUserViewModel : ObservableObject
    {
        public int ProjectId { get; set; }
        
        [ObservableProperty] private string? _email;
        [ObservableProperty] private string? _message;

        public Action? CloseAction { get; set; }

        [RelayCommand]
        public async Task SendInviteAsync()
        {
            if (string.IsNullOrWhiteSpace(Email))
            {
                MessageBox.Show("Podaj adres email użytkownika!", "Błąd walidacji", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!Regex.IsMatch(Email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                MessageBox.Show("Podaj poprawny format adresu email.", "Błąd walidacji", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            
            string finalMessage = string.IsNullOrWhiteSpace(Message) ? "Zapraszam do mojego projektu!" : Message;

            bool success = await ApiService.Instance.SendInvitationAsync(ProjectId, Email, finalMessage);

            if (success)
            {
                MessageBox.Show("Zaproszenie zostało pomyślnie wysłane!", "Sukces", MessageBoxButton.OK, MessageBoxImage.Information);
                CloseAction?.Invoke();
            }
            else
            {
                MessageBox.Show("Nie udało się wysłać zaproszenia. Sprawdź, czy użytkownik istnieje w systemie.", "Błąd", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}