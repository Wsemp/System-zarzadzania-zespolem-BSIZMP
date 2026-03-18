using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using System;

namespace desktopapp.ViewModels
{
    public partial class AddTaskViewModel : ObservableObject
    {
        [ObservableProperty] private string _title;
        [ObservableProperty] private string _description;
        [ObservableProperty] private string _status = "Do zrobienia";
        [ObservableProperty] private string _assignedUser;

        public Action CloseAction { get; set; }

        public TaskModel CreatedTask { get; private set; }

        [RelayCommand]
        public void Save()
        {
            CreatedTask = new TaskModel
            {
                Title = this.Title,
                Description = this.Description,
                Status = this.Status,
                AssignedUser = this.AssignedUser
            };

            CloseAction?.Invoke();
        }
    }
}