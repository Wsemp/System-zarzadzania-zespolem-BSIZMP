using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using System;
using System.Collections.ObjectModel;

namespace desktopapp.ViewModels
{
    public partial class AddTaskViewModel : ObservableObject
    {
        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(SaveCommand))]
        private string _title;

        [ObservableProperty]
        private string _description;

        [ObservableProperty]
        private string _status = "Do zrobienia";

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(SaveCommand))]
        private string _assignedUser;

        [ObservableProperty]
        private ObservableCollection<string> _availableUsernames;

        public Action CloseAction { get; set; }

        public TaskModel CreatedTask { get; private set; }

        private bool CanSave()
        {
            return !string.IsNullOrWhiteSpace(Title) && !string.IsNullOrWhiteSpace(AssignedUser);
        }

        [RelayCommand(CanExecute = nameof(CanSave))]
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