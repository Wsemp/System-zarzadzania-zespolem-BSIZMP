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
        private ObservableCollection<ProjectModel> _availableProjects;

        [ObservableProperty]
        private ProjectModel _selectedProject;
        
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

        public System.Collections.Generic.List<UserModel> ApiUsers { get; set; }

        private bool CanSave()
        {
            return !string.IsNullOrWhiteSpace(Title) && !string.IsNullOrWhiteSpace(AssignedUser);
        }

        [RelayCommand(CanExecute = nameof(CanSave))]
        public void Save()
        {
            var selectedUser = ApiUsers?.Find(u => u.Username == this.AssignedUser);

            string statusKey = Status switch
            {
                "Do zrobienia" => "todo",
                "W trakcie" => "in_progress",
                "Zakończone" => "done",
                _ => "todo"
            };

            CreatedTask = new TaskModel
            {
                Title = this.Title,
                Description = this.Description ?? string.Empty,
                Status = statusKey,
                AssignedUser = this.AssignedUser,
                AssignedToId = selectedUser?.Id,
                TagIds = new System.Collections.Generic.List<int>(),
                ProjectId = SelectedProject?.Id 
            };

            CloseAction?.Invoke();
        }

        [RelayCommand]
        public void Close()
        {
            CreatedTask = null; // Zabezpieczenie przed zapisem przy anulowaniu
            CloseAction?.Invoke();
        }
    }
}