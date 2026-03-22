using CommunityToolkit.Mvvm.ComponentModel;

namespace desktopapp.Models
{
    public partial class TaskModel : ObservableObject
    {
        [ObservableProperty]
        private int _id;

        [ObservableProperty]
        private string _title;

        [ObservableProperty]
        private string _description;

        [ObservableProperty]
        private string _status;

        [ObservableProperty]
        private string _assignedUser;
    }
}