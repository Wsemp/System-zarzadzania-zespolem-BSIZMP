using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using desktopapp.Models;
using desktopapp.Services;
using desktopapp.Views;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks; 

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
        private ProjectModel _selectedProjectFilter;

        partial void OnSelectedProjectFilterChanged(ProjectModel value)
        {
            ApplyFilters(); 
        }

        [ObservableProperty]
        private ObservableCollection<string> _availableUsernames = new ObservableCollection<string>();

        private List<UserModel> _apiUsers = new List<UserModel>();
        
        public MainViewModel()
        {
            _ = InitializeDataAsync();
            StartAutoRefresh();
        }

        private async Task InitializeDataAsync()
        {
            await LoadApiUsersAsync();
            await LoadProjectsFromApiAsync(); 
            await LoadTasksAsync();           
            LoadUserProfile();
        }

        private void LoadUserProfile()
        {
            CurrentUserName = ApiService.Instance.LoggedInUsername ?? "Nieznany użytkownik";

            if (_apiUsers != null)
            {
                var me = _apiUsers.FirstOrDefault(u => u.Username == CurrentUserName);
                if (me != null)
                {
                    CurrentUserEmail = me.Email;
                }
                else
                {
                    CurrentUserEmail = "Brak emaila w bazie";
                }
            }
        }

        private async Task RefreshTasksSilentlyAsync()
        {
            try
            {
                var newTasks = await ApiService.Instance.GetTasksAsync();
                
                if (newTasks != null)
                {
                    foreach (var task in newTasks)
                    {
                        if (_apiUsers != null && task.AssignedToId.HasValue)
                        {
                            var user = _apiUsers.FirstOrDefault(u => u.Id == task.AssignedToId.Value);
                            if (user != null)
                            {
                                task.AssignedUser = user.Username;
                            }
                        }
                    }
                    
                    int? selectedId = SelectedTask?.Id;
                    _allTasks = newTasks;
                    ApplyFilters();
                    
                    if (selectedId.HasValue)
                    {
                        SelectedTask = Tasks.FirstOrDefault(t => t.Id == selectedId.Value);
                    }
                }
            }
            catch { }
        }
        
        private System.Windows.Threading.DispatcherTimer _refreshTimer;

        private void StartAutoRefresh()
        {
            _refreshTimer = new System.Windows.Threading.DispatcherTimer();
            _refreshTimer.Interval = TimeSpan.FromSeconds(10); 
            _refreshTimer.Tick += async (s, e) => await RefreshTasksSilentlyAsync();
            _refreshTimer.Start();
        }
        
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
        
        private async Task LoadTasksAsync()
        {
            _allTasks = await ApiService.Instance.GetTasksAsync();

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

            ApplyFilters(); 
        }

        private async Task LoadProjectsFromApiAsync()
        {
            var apiProjects = await ApiService.Instance.GetProjectsAsync();
            
            var tempList = new ObservableCollection<ProjectModel>();
            
            // "Wszystkie projekty" ląduje zawsze na pozycji 0
            tempList.Add(new ProjectModel { Id = 0, Name = "--- Wszystkie projekty ---", Description = "Pokazuje wszystko" });
            
            foreach (var p in apiProjects)
            {
                tempList.Add(p);
            }

            Projects = tempList;

            // KRYTYCZNA ZMIANA:
            // Wcześniej mieliśmy: if (SelectedProjectFilter == null)
            // Zmień to tak, aby ZAWSZE ustawiało wartość domyślną po odświeżeniu, jeśli jej brak, 
            // a jeśli była jakaś wybrana (np. jesteś w trakcie przeglądania Projektu X), żeby do niego wróciła!
            
            if (SelectedProjectFilter == null)
            {
                SelectedProjectFilter = Projects.First();
            }
            else
            {
                // Znajdź projekt na nowej liście o tym samym ID, co ten wybrany poprzednio
                var staryWybor = Projects.FirstOrDefault(p => p.Id == SelectedProjectFilter.Id);
                SelectedProjectFilter = staryWybor ?? Projects.First();
            }
        }

        partial void OnSearchUserTextChanged(string value)
        {
            ApplyFilters(); 
        }

        private void ApplyFilters()
        {
            if (_allTasks == null) return;

            var filtered = _allTasks.AsEnumerable();
            
            // Zmieniliśmy tutaj, aby pominąć nulla bezpiecznie
            if (SelectedProjectFilter != null) 
            {
                if (SelectedProjectFilter.Id != 0) // Jeśli to NIE jest 0 ("Wszystkie")
                {
                    filtered = filtered.Where(t => t.ProjectId == SelectedProjectFilter.Id);
                }
            }
            
            if (!string.IsNullOrWhiteSpace(SearchUserText))
            {
                filtered = filtered.Where(t => t.AssignedUser != null && t.AssignedUser.Contains(SearchUserText, StringComparison.OrdinalIgnoreCase));
            }

            // Na koniec upewnijmy się, że UI na pewno dostało informację o nowej liście
            Tasks = new ObservableCollection<TaskModel>(filtered.ToList());
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
            
            if (Projects != null)
            {
                addTaskVm.AvailableProjects = new ObservableCollection<ProjectModel>(Projects.Where(p => p.Id != 0));
                
                if (SelectedProjectFilter != null && SelectedProjectFilter.Id != 0)
                {
                    addTaskVm.SelectedProject = addTaskVm.AvailableProjects.FirstOrDefault(p => p.Id == SelectedProjectFilter.Id);
                }
            }

            var window = new Views.AddTaskWindow(addTaskVm);
            window.ShowDialog();

            if (addTaskVm.CreatedTask != null)
            {
                bool isSuccess = await ApiService.Instance.CreateTaskAsync(addTaskVm.CreatedTask);

                if (isSuccess)
                {
                    await LoadTasksAsync();
                    ApplyFilters(); 
                    Services.NotificationService.Instance.Show("Zadanie zapisane w chmurze!");
                }
                else
                {
                    addTaskVm.CreatedTask.Id = _allTasks.Any() ? _allTasks.Max(t => t.Id) + 1 : 1;
                    _allTasks.Insert(0, addTaskVm.CreatedTask);
                    ApplyFilters(); 
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
            
            if (Projects != null)
            {
                editTaskVm.AvailableProjects = new ObservableCollection<ProjectModel>(Projects.Where(p => p.Id != 0));
                editTaskVm.SelectedProject = editTaskVm.AvailableProjects.FirstOrDefault(p => p.Id == SelectedTask.ProjectId);
            }

            var window = new Views.AddTaskWindow(editTaskVm);
            window.ShowDialog();

            if (editTaskVm.CreatedTask != null)
            {
                editTaskVm.CreatedTask.Id = SelectedTask.Id;

                bool isSuccess = await ApiService.Instance.UpdateTaskAsync(editTaskVm.CreatedTask);

                if (isSuccess)
                {
                    await LoadTasksAsync();
                    ApplyFilters();
                    Services.NotificationService.Instance.Show("Zadanie zaktualizowane pomyślnie!");
                }
                else
                {
                    Services.NotificationService.Instance.Show("Błąd aktualizacji na serwerze!");
                }
            }
        }
        
        [RelayCommand]
        public async void AddProject()
        {
            if (string.IsNullOrWhiteSpace(NewProjectName))
            {
                Services.NotificationService.Instance.Show("Podaj nazwę projektu!");
                return;
            }

            var nowyProjekt = new ProjectModel
            {
                Name = this.NewProjectName,
                Description = this.NewProjectDescription ?? ""
            };

            bool isSuccess = await ApiService.Instance.CreateProjectAsync(nowyProjekt);

            if (isSuccess)
            {
                Services.NotificationService.Instance.Show("Utworzono nowy projekt!");
                NewProjectName = string.Empty;
                NewProjectDescription = string.Empty;
                
                await LoadProjectsFromApiAsync(); 
            }
            else
            {
                Services.NotificationService.Instance.Show("Błąd! Nie udało się utworzyć projektu.");
            }
        }

        [ObservableProperty]
        private string _currentUserName;

        [ObservableProperty]
        private string _currentUserEmail;

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