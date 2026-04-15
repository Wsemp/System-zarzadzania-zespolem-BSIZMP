using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using desktopapp.Services;
using desktopapp.Views;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks; // Dodane, żeby Task.WhenAll zadziałało

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
            LoadMockProjects();
            // Zmienione: Wywołujemy jedną metodę inicjalizacyjną, która zachowuje kolejność
            _ = InitializeDataAsync();
        }

        private async Task InitializeDataAsync()
        {
            // 1. NAJPIERW pobierz użytkowników
            await LoadApiUsersAsync();
            // 2. DOPIERO POTEM pobierz zadania i przypisz imiona (teraz to zadziała, bo _apiUsers jest pełne)
            await LoadTasksAsync();
        }

        // Zmienione na async Task, żeby można było na to "poczekać"
        private async Task LoadApiUsersAsync()
        {
            try
            {
                _apiUsers = await ApiService.Instance.GetUsersAsync();

                if (_apiUsers != null && _apiUsers.Any())
                {
                    var usernamesList = _apiUsers.Select(u => u.Username).ToList();
                    AvailableUsernames = new ObservableCollection<string>(usernamesList);
                }
                else
                {
                    AvailableUsernames = new ObservableCollection<string> { "Brak danych (Tryb Offline)" };
                }
            }
            catch
            {
                AvailableUsernames = new ObservableCollection<string> { "Brak danych (Tryb Offline)" };
            }
        }

        // Zmienione na async Task
        private async Task LoadTasksAsync()
        {
            _allTasks = await ApiService.Instance.GetTasksAsync();

            // --- KLUCZOWE: TŁUMACZENIE ID NA IMIONA DLA TABELI ---
            if (_apiUsers != null && _apiUsers.Any())
            {
                foreach (var task in _allTasks)
                {
                    if (task.AssignedToId.HasValue)
                    {
                        var user = _apiUsers.FirstOrDefault(u => u.Id == task.AssignedToId.Value);
                        if (user != null)
                        {
                            task.AssignedUser = user.Username;
                        }
                    }
                }
            }

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
                var filtered = _allTasks.Where(t => t.AssignedUser != null && t.AssignedUser.Contains(value, StringComparison.OrdinalIgnoreCase));
                Tasks = new ObservableCollection<TaskModel>(filtered);
            }
        }

        [RelayCommand]
        public async void DeleteTask()
        {
            if (SelectedTask != null)
            {
                var taskToDelete = SelectedTask;

                bool isSuccess = await ApiService.Instance.DeleteTaskAsync(taskToDelete.Id);

                if (isSuccess)
                {
                    _allTasks.Remove(taskToDelete);
                    Tasks.Remove(taskToDelete);


                    ApiService.Instance.SaveTasksOffline(_allTasks);

                    Services.NotificationService.Instance.Show("Zadanie usunięto z chmury!");
                }
                else
                {

                    Services.NotificationService.Instance.Show("Błąd: Nie udało się usunąć zadania z serwera.");
                }
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

                    await LoadTasksAsync();
                    Services.NotificationService.Instance.Show("Zadanie zapisane w chmurze!");
                }
                else
                {
                    addTaskVm.CreatedTask.Id = _allTasks.Any() ? _allTasks.Max(t => t.Id) + 1 : 1;

                    _allTasks.Insert(0, addTaskVm.CreatedTask);
                    Tasks = new System.Collections.ObjectModel.ObservableCollection<TaskModel>(_allTasks);

                    ApiService.Instance.SaveTasksOffline(_allTasks);

                    Services.NotificationService.Instance.Show("Brak sieci. Zadanie zapisano lokalnie!");
                }
            }
        }

        [RelayCommand]
        public async void EditTask()
        {
            if (SelectedTask == null)
            {
                Services.NotificationService.Instance.Show("Wybierz zadanie z listy, aby je edytować!");
                return;
            }

            var editTaskVm = new AddTaskViewModel();
            editTaskVm.AvailableUsernames = this.AvailableUsernames;
            editTaskVm.ApiUsers = this._apiUsers;

            editTaskVm.Title = SelectedTask.Title;
            editTaskVm.Description = SelectedTask.Description;
            editTaskVm.AssignedUser = SelectedTask.AssignedUser;
            editTaskVm.Status = SelectedTask.DisplayStatus;

            var window = new Views.AddTaskWindow(editTaskVm);
            window.ShowDialog();

            if (editTaskVm.CreatedTask != null)
            {
                editTaskVm.CreatedTask.Id = SelectedTask.Id;


                bool isSuccess = await ApiService.Instance.UpdateTaskAsync(editTaskVm.CreatedTask);

                if (isSuccess)
                {
                    await LoadTasksAsync();
                    Services.NotificationService.Instance.Show("Zadanie zaktualizowane pomyślnie!");
                }
                else
                {
                    Services.NotificationService.Instance.Show("Błąd aktualizacji na serwerze!");
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
        public async void SaveProfile()
        {
            if (string.IsNullOrWhiteSpace(NewPassword))
            {
                Services.NotificationService.Instance.Show("Wpisz nowe hasło, aby zapisać zmiany!");
                return;
            }

            var currentUser = _apiUsers.FirstOrDefault(u => u.Username == CurrentUserName);

            if (currentUser != null)
            {
                bool isSuccess = await ApiService.Instance.UpdateProfileAsync(currentUser.Id, NewPassword);

                if (isSuccess)
                {
                    Services.NotificationService.Instance.Show("Hasło zostało pomyślnie zmienione w chmurze!");
                    NewPassword = string.Empty;
                }
                else
                {
                    Services.NotificationService.Instance.Show("Błąd: Serwer odrzucił zmianę hasła.");
                }
            }
            else
            {
                Services.NotificationService.Instance.Show("Błąd: Nie odnaleziono Twojego profilu w pobranej bazie.");
            }
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