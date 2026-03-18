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

        public MainViewModel()
        {
            LoadMockData();
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
    }
}