using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using desktopapp.Services;
using desktopapp.Views;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;



namespace desktopapp.ViewModels
{

    
    public partial class MainViewModel : ObservableObject
    {
        private List<TaskModel> _allTasks = new List<TaskModel>();

        [ObservableProperty]
        private ObservableCollection<TaskModel> _tasks;

        [ObservableProperty]
        private TaskModel _selectedTask;

        [ObservableProperty]
        private string _searchUserText;

        [ObservableProperty]
        private ObservableCollection<ProjectModel> _projects;

        [ObservableProperty]
        private string _newProjectName;

        [ObservableProperty]
        private string _newProjectDescription;

        [ObservableProperty]
        private ObservableCollection<string> _availableUsernames = new ObservableCollection<string>();

        private List<UserModel> _apiUsers = new List<UserModel>();

        public MainViewModel()
        {
            LoadTasksAsync();
            LoadMockProjects();
            LoadApiUsersAsync(); 
        }

        private async void LoadApiUsersAsync()
        {
            _apiUsers = await ApiService.Instance.GetUsersAsync();
            var usernamesList = _apiUsers.Select(u => u.Username).ToList();
            AvailableUsernames = new ObservableCollection<string>(usernamesList);
        }

        private async void LoadTasksAsync()
        {
            _allTasks = await ApiService.Instance.GetTasksAsync();
            Tasks = new ObservableCollection<TaskModel>(_allTasks);
        }

        private void LoadMockProjects()
        {
            Projects = new ObservableCollection<ProjectModel>
            {
                new ProjectModel { Id = 1, Name = "Aplikacja Webowa", Description = "Backend w Django i frontend w React" },
                new ProjectModel { Id = 2, Name = "Aplikacja Mobilna", Description = "Apka we Flutterze dla klientów" },
                new ProjectModel { Id = 3, Name = "Panel Admina", Description = "Aplikacja WPF w C#" }
            };
        }

        partial void OnSearchUserTextChanged(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                Tasks = new ObservableCollection<TaskModel>(_allTasks);
            }
            else
            {
                var filtered = _allTasks.Where(t => t.AssignedUser.Contains(value, StringComparison.OrdinalIgnoreCase));
                Tasks = new ObservableCollection<TaskModel>(filtered);
            }
        }

        [RelayCommand]
        public void DeleteTask()
        {
            if (SelectedTask != null)
            {
                _allTasks.Remove(SelectedTask);
                Tasks.Remove(SelectedTask);

                ApiService.Instance.SaveTasksOffline(_allTasks);

                Services.NotificationService.Instance.Show("Zadanie zostało usunięte!");
            }
        }

        [RelayCommand]

        public async void OpenAddTaskWindow()
        {
            var addTaskVm = new AddTaskViewModel();
            addTaskVm.AvailableUsernames = this.AvailableUsernames;
            addTaskVm.ApiUsers = this._apiUsers;

            var window = new Views.AddTaskWindow(addTaskVm);
            window.ShowDialog();

            if (addTaskVm.CreatedTask != null)
            {
                bool isSuccess = await ApiService.Instance.CreateTaskAsync(addTaskVm.CreatedTask);

                if (isSuccess)
                {
                    LoadTasksAsync();

                    Services.NotificationService.Instance.Show("Nowe zadanie dodane pomyślnie!");
                }
                else
                {
                    Services.NotificationService.Instance.Show("Błąd zapisu na serwerze!");
                }
            }
        }

        [RelayCommand]
        public void AddProject()
        {
            if (!string.IsNullOrWhiteSpace(NewProjectName))
            {
                var nowyProjekt = new ProjectModel
                {
                    Id = Projects.Count + 1,
                    Name = this.NewProjectName,
                    Description = this.NewProjectDescription
                };

                Projects.Add(nowyProjekt);

                NewProjectName = string.Empty;
                NewProjectDescription = string.Empty;
            }
        }


        [ObservableProperty]
        private string _currentUserName = "admin";

        [ObservableProperty]
        private string _currentUserEmail = "admin@mojsystem.pl";

        [ObservableProperty]
        private string _newPassword;

        [RelayCommand]
        public void SaveProfile()
        {
            System.Windows.MessageBox.Show($"Zapisano zmiany dla profilu: {CurrentUserName}", "Sukces");
            NewPassword = string.Empty;
        }

        [RelayCommand]
        public void Logout()
        {
            ApiService.Instance.Logout();

            var loginWindow = new LoginView();
            loginWindow.Show();

            foreach (System.Windows.Window window in System.Windows.Application.Current.Windows)
            {
                if (window is MainWindow) 
                {
                    window.Close();
                    break;
                }
            }
        }
        public Services.NotificationService Notifier => Services.NotificationService.Instance;
    }
}