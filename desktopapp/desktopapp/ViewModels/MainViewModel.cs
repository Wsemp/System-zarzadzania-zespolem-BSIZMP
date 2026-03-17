using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using System.Collections.ObjectModel;

namespace desktopapp.ViewModels
{
    public partial class MainViewModel : ObservableObject
    {
        [ObservableProperty]
        private ObservableCollection<TaskModel> _tasks;

        public MainViewModel()
        {
            LoadMockData();
        }

        private void LoadMockData()
        {
            Tasks = new ObservableCollection<TaskModel>
            {
                new TaskModel { Id = 1, Title = "Zaprojektować bazę danych", Description = "Baza w MySQL dla Django", Status = "W trakcie", AssignedUser = "Kuba (Backend)" },
                new TaskModel { Id = 2, Title = "Zrobić API logowania", Description = "Endpoint /api/login", Status = "Do zrobienia", AssignedUser = "Kuba (Backend)" },
                new TaskModel { Id = 3, Title = "Widok listy zadań WPF", Description = "Tabela w Desktopie", Status = "Zakończone", AssignedUser = "Ja (Desktop)" },
                new TaskModel { Id = 4, Title = "Makiety w Figmie", Description = "Kolory i przyciski dla mobile", Status = "Do zrobienia", AssignedUser = "Kasia (Mobile)" }
            };
        }
        [RelayCommand]
        public void OpenAddTaskWindow()
        {
            var addTaskVm = new AddTaskViewModel();

            var window = new Views.AddTaskWindow(addTaskVm);
            window.ShowDialog();
            if (addTaskVm.CreatedTask != null)
            {
                addTaskVm.CreatedTask.Id = Tasks.Count + 1;
                Tasks.Insert(0, addTaskVm.CreatedTask);
            }
        }
    }
}