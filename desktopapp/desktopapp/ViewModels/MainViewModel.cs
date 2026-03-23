using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
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

        public MainViewModel()
        {
            LoadMockData();
            LoadMockProjects();
        }

        private void LoadMockData()
        {
            _allTasks = new List<TaskModel>
            {
                new TaskModel { Id = 1, Title = "Zaprojektować bazę danych", Description = "Baza w MySQL", Status = "W trakcie", AssignedUser = "Kuba" },
                new TaskModel { Id = 2, Title = "Zrobić API logowania", Description = "Endpoint /api/login", Status = "Do zrobienia", AssignedUser = "Kuba" },
                new TaskModel { Id = 3, Title = "Widok listy zadań WPF", Description = "Tabela w Desktopie", Status = "Zakończone", AssignedUser = "Michał" },
                new TaskModel { Id = 4, Title = "Makiety w Figmie", Description = "Kolory i przyciski", Status = "Do zrobienia", AssignedUser = "Kasia" }
            };

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
            }
        }

        [RelayCommand]
        public void OpenAddTaskWindow()
        {
            var addTaskVm = new AddTaskViewModel();

            var window = new Views.AddTaskWindow(addTaskVm);
            window.ShowDialog();

            if (addTaskVm.CreatedTask != null)
            {
                addTaskVm.CreatedTask.Id = _allTasks.Count + 1;
                _allTasks.Insert(0, addTaskVm.CreatedTask);
                Tasks.Insert(0, addTaskVm.CreatedTask);
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

    }
}