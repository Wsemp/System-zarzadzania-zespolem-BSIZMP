using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using System;
using System.Collections.ObjectModel;
using System.Linq;

namespace desktopapp.ViewModels
{
    public partial class AddTaskViewModel : ObservableObject
    {
        [ObservableProperty]
        private ObservableCollection<ProjectModel>? _availableProjects;

        [ObservableProperty]
        private ProjectModel? _selectedProject;
        
        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(SaveCommand))]
        private string? _title;

        [ObservableProperty]
        private string? _description;

        [ObservableProperty]
        private string _status = "Do zrobienia";

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(SaveCommand))]
        private string? _assignedUser;

        [ObservableProperty]
        private ObservableCollection<string?>? _availableUsernames;

        [ObservableProperty]
        private DateTime? _dueDate;

        public Action? CloseAction { get; set; }

        public TaskModel? CreatedTask { get; private set; }

        public System.Collections.Generic.List<UserModel>? ApiUsers { get; set; }

        partial void OnSelectedProjectChanged(ProjectModel? value)
        {
            if (value != null)
            {
                System.Windows.MessageBox.Show($"Wybrano projekt: {value.Name}\nLiczba członków w pamięci: {value.Members?.Count ?? 0}");

                if (value.Members != null && value.Members.Any())
                {
                    var names = value.Members.Where(m => m != null).Select(m => m.Username);
                    AvailableUsernames = new ObservableCollection<string?>(names);
                }
                else
                {
                    AvailableUsernames = new ObservableCollection<string?>();
                }
            }
            else
            {
                AvailableUsernames = new ObservableCollection<string?>();
            }
            
            AssignedUser = null;
        }

        private bool CanSave()
        {
            return !string.IsNullOrWhiteSpace(Title) && !string.IsNullOrWhiteSpace(AssignedUser);
        }

        [RelayCommand(CanExecute = nameof(CanSave))]
        public void Save()
        {
            var selectedUser = SelectedProject?.Members.FirstOrDefault(u => u.Username == AssignedUser);

            string statusKey = Status switch
            {
                "Do zrobienia" => "todo",
                "W trakcie" => "In progress",
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
                DueDate = this.DueDate,
                TagIds = new System.Collections.Generic.List<int>(),
                ProjectId = SelectedProject?.Id 
            };

            CloseAction?.Invoke();
        }

        [RelayCommand]
        public void Close()
        {
            CreatedTask = null;
            CloseAction?.Invoke();
        }
    }
}