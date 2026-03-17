using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System.Threading.Tasks;
using System.Windows;
using desktopapp.Services;

namespace desktopapp.ViewModels
{
    public partial class LoginViewModel : ObservableObject
    {
        [ObservableProperty]
        private string _username;

        [ObservableProperty]
        private string _password;


        [RelayCommand]
        public async Task LoginAsync()
        {

            bool isSuccess = await ApiService.Instance.LoginAsync(Username, Password);

            if (isSuccess)
            {
                var mainWindow = new MainWindow();
                mainWindow.Show();

                foreach (Window window in Application.Current.Windows)
                {
                    if (window is Views.LoginView)
                    {
                        window.Close();
                        break;
                    }
                }
            }
            else
            {
                MessageBox.Show("Błędny login, hasło lub brak połączenia z serwerem.", "Błąd logowania");
            }
        }
    }
}