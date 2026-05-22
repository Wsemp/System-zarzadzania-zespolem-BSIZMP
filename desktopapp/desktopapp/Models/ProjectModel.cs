using CommunityToolkit.Mvvm.ComponentModel;
using Newtonsoft.Json;
using System.Collections.ObjectModel;
using System.ComponentModel.DataAnnotations.Schema; // 🔥 TO JEST WAŻNE 🔥

namespace desktopapp.Models
{
    public partial class ProjectModel : ObservableObject
    {
        [ObservableProperty]
        private int _id;

        [ObservableProperty]
        private string? _name;

        [ObservableProperty]
        private string? _description;

        [NotMapped]
        [JsonProperty("members")]
        
        
        public ObservableCollection<UserModel> Members { get; set; } = new ObservableCollection<UserModel>();
        
        [NotMapped]
        [JsonProperty("owner")]
        public UserModel? Owner { get; set; }
    }
}