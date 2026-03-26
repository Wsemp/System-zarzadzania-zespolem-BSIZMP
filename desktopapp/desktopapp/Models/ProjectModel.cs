using CommunityToolkit.Mvvm.ComponentModel;

namespace desktopapp.Models
{
    public partial class ProjectModel : ObservableObject
    {
        [ObservableProperty]
        private int _id;

        [ObservableProperty]
        private string _name;

        [ObservableProperty]
        private string _description;
    }
}