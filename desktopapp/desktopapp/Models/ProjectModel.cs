using CommunityToolkit.Mvvm.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace desktopapp.Models
{
    public partial class ProjectModel : ObservableObject
    {
        [Key]
        [ObservableProperty]
        private int _id;

        [ObservableProperty]
        private string? _name;

        [ObservableProperty]
        private string? _description;
    }
}