using CommunityToolkit.Mvvm.ComponentModel;
using System.Threading.Tasks;

namespace desktopapp.Services
{
    public partial class NotificationService : ObservableObject
    {
        private static NotificationService _instance;
        public static NotificationService Instance => _instance ??= new NotificationService();

        [ObservableProperty]
        private string _message;

        [ObservableProperty]
        private bool _isVisible;

        public async void Show(string message, int durationSeconds = 3)
        {
            Message = message;
            IsVisible = true;
            await Task.Delay(durationSeconds * 1000);
            IsVisible = false;
        }
    }
}