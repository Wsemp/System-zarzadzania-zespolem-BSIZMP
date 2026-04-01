using CommunityToolkit.Mvvm.ComponentModel;

namespace desktopapp.Models
{
    public partial class UserModel : ObservableObject
    {
        [ObservableProperty]
        private string _username;

        [ObservableProperty]
        private string _email;
    }
}