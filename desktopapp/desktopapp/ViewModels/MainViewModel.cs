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
using System.Windows.Threading;

namespace desktopapp.ViewModels
{
    public partial class MainViewModel : ObservableObject
    {
        private List<TaskModel> _allTasks = new List<TaskModel>();

        [ObservableProperty]
        private ObservableCollection<TaskModel>? _tasks;

        [ObservableProperty]
        [NotifyCanExecuteChangedFor(nameof(EditTaskCommand))]
        private TaskModel? _selectedTask;

        [ObservableProperty]
        private string? _searchUserText;

        [ObservableProperty]
        private ObservableCollection<ProjectModel>? _projects;

        [ObservableProperty]
        private string? _newProjectName;

        [ObservableProperty]
        private string? _newProjectDescription;
        
        [ObservableProperty]
        private ProjectModel? _selectedProject;

        [ObservableProperty]
        private string _projectFormTitle = "Utwórz nowy projekt";

        [ObservableProperty]
        private string _projectButtonText = "Dodaj projekt";

        private int? _editingProjectId;
        
        [ObservableProperty]
        private ProjectModel? _selectedProjectFilter;

        partial void OnSelectedProjectFilterChanged(ProjectModel? value)
        {
            ApplyFilters(); 
        }
        
        [ObservableProperty]
        private bool _showOnlyMyTasks;

        partial void OnShowOnlyMyTasksChanged(bool value)
        {
            ApplyFilters(); 
        }

        [ObservableProperty]
        private DateTime? _selectedFilterDate;

        partial void OnSelectedFilterDateChanged(DateTime? value)
        {
            ApplyFilters();
        }

        [RelayCommand]
        public void ClearFilterDate()
        {
            SelectedFilterDate = null;
        }

        [ObservableProperty]
        private int _totalTasksCount;

        [ObservableProperty]
        private int _completedTasksCount;

        [ObservableProperty]
        private int _inProgressTasksCount;

        [ObservableProperty]
        private ObservableCollection<string> _availableUsernames = new ObservableCollection<string>();

        [ObservableProperty]
        private ObservableCollection<UserModel> _apiUsersList = new ObservableCollection<UserModel>();

        private List<UserModel> _apiUsers = new List<UserModel>();
        
        [ObservableProperty]
        private string _selectedView = "Zadania";

        [ObservableProperty]
        private ObservableCollection<InvitationModel> _pendingInvitations = new ObservableCollection<InvitationModel>();

        [ObservableProperty]
        private ObservableCollection<NotificationModel> _notifications = new ObservableCollection<NotificationModel>();

        [ObservableProperty]
        private bool _isNotificationsPanelOpen;
        
        [RelayCommand]
        public void SwitchView(string viewName)
        {
            if (!string.IsNullOrEmpty(viewName))
            {
                SelectedView = viewName;
            }
        }

        [RelayCommand]
        public async Task ToggleNotificationsPanel()
        {
            IsNotificationsPanelOpen = !IsNotificationsPanelOpen;
            if (IsNotificationsPanelOpen)
            {
                await LoadNotificationsAsync();
            }
        }

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
            await LoadInboxAsync();
            LoadUserProfile();
        }

        private async Task LoadInboxAsync()
        {
            var loadInvitationsTask = ApiService.Instance.GetPendingInvitationsAsync();
            var loadNotificationsTask = ApiService.Instance.GetNotificationsAsync();

            await Task.WhenAll(loadInvitationsTask, loadNotificationsTask);

            // Filtrujemy zaproszenia (tylko niezaakceptowane)
            PendingInvitations = new ObservableCollection<InvitationModel>(loadInvitationsTask.Result.Where(i => !i.Accepted));
            
            var notificationsList = loadNotificationsTask.Result;
            
            // 🔥 DOPASOWANIE ZADAŃ DO POWIADOMIEŃ 🔥
            foreach (var notif in notificationsList)
            {
                if (!string.IsNullOrEmpty(notif.TaskUrl))
                {
                    var parts = notif.TaskUrl.TrimEnd('/').Split('/');
                    if (int.TryParse(parts.Last(), out int taskId))
                    {
                        // Szukamy zadania po ID na naszej liście
                        var task = _allTasks?.FirstOrDefault(t => t.Id == taskId);
                        
                        // Jeśli znaleźliśmy, bierzemy Tytuł. Jak nie, dajemy sam numerek.
                        notif.TaskTitle = task != null ? $"Zadanie: {task.Title}" : $"Zadanie #{taskId}";
                    }
                }
            }

            Notifications = new ObservableCollection<NotificationModel>(notificationsList);
        }

        private async Task LoadInvitationsAsync()
        {
            var invitations = await ApiService.Instance.GetPendingInvitationsAsync();
            PendingInvitations = new ObservableCollection<InvitationModel>(invitations);
        }

        private async Task LoadNotificationsAsync()
        {
            var notifications = await ApiService.Instance.GetNotificationsAsync();
            Notifications = new ObservableCollection<NotificationModel>(notifications);
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
            ApplyFilters();
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
                        SelectedTask = Tasks?.FirstOrDefault(t => t.Id == selectedId.Value);
                    }
                }
            }
            catch { }
        }
        
        private DispatcherTimer? _refreshTimer;

        private void StartAutoRefresh()
        {
            _refreshTimer = new System.Windows.Threading.DispatcherTimer();
            _refreshTimer.Interval = TimeSpan.FromSeconds(10); 
            _refreshTimer.Tick += async (s, e) => 
            {
                await RefreshTasksSilentlyAsync();
                await LoadInboxAsync();
            };
            _refreshTimer.Start();
        }
        
        private async Task LoadApiUsersAsync()
        {
            try
            {
                _apiUsers = await ApiService.Instance.GetUsersAsync();

                if (_apiUsers != null && _apiUsers.Any())
                {
                    var usernamesList = _apiUsers.Select(u => u.Username).Where(u => u != null).Select(u => u!);
                    AvailableUsernames = new ObservableCollection<string>(usernamesList);
                    ApiUsersList = new ObservableCollection<UserModel>(_apiUsers);
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
    
            tempList.Add(new ProjectModel { Id = 0, Name = "--- Wszystkie projekty ---", Description = "Pokazuje wszystko" });
    
            foreach (var p in apiProjects)
            {
                bool isOwner = p.Owner != null && p.Owner.Username == CurrentUserName;
                bool isMember = p.Members != null && p.Members.Any(m => m.Username == CurrentUserName);
                
                if (isOwner || isMember)
                {
                    tempList.Add(p);
                }
            }

            Projects = tempList;
    
            if (SelectedProjectFilter == null)
            {
                SelectedProjectFilter = Projects.First();
            }
            else
            {
                var staryWybor = Projects.FirstOrDefault(p => p.Id == SelectedProjectFilter.Id);
                SelectedProjectFilter = staryWybor ?? Projects.First();
            }
        }

        partial void OnSearchUserTextChanged(string? value)
        {
            ApplyFilters(); 
        }

        public void ApplyFilters()
        {
            if (_allTasks == null) return;

            var filtered = _allTasks.AsEnumerable();
            if (SelectedProjectFilter != null && SelectedProjectFilter.Id != 0) 
            {
                filtered = filtered.Where(t => t.ProjectId == SelectedProjectFilter.Id);
            }
            if (!string.IsNullOrWhiteSpace(SearchUserText))
            {
                filtered = filtered.Where(t => t.AssignedUser != null && t.AssignedUser.Contains(SearchUserText, StringComparison.OrdinalIgnoreCase));
            }
            if (ShowOnlyMyTasks && !string.IsNullOrEmpty(CurrentUserName))
            {
                filtered = filtered.Where(t => t.AssignedUser == CurrentUserName);
            }
            if (SelectedFilterDate.HasValue)
            {
                filtered = filtered.Where(t => t.DueDate.HasValue && t.DueDate.Value.Date <= SelectedFilterDate.Value.Date);
            }

            var finalList = filtered.ToList();
            Tasks = new ObservableCollection<TaskModel>(finalList);
            TotalTasksCount = finalList.Count;
            CompletedTasksCount = finalList.Count(t => t.DisplayStatus == "Zakończone");
            InProgressTasksCount = finalList.Count(t => t.DisplayStatus == "W trakcie");
        }

        [RelayCommand]
        public async Task DeleteTask()
        {
            if (SelectedTask != null)
            {
                var taskToDelete = SelectedTask;

                bool isSuccess = await ApiService.Instance.DeleteTaskAsync(taskToDelete.Id);

                if (isSuccess)
                {
                    _allTasks.Remove(taskToDelete);
                    Tasks?.Remove(taskToDelete);
                    
                    NotificationService.Instance.Show("Zadanie usunięto z chmury!");
                    ApplyFilters();
                }
                else
                {
                    NotificationService.Instance.Show("Błąd: Nie udało się usunąć zadania z serwera.");
                }
            }
        }

        [RelayCommand]
        public async Task OpenAddTaskWindow()
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
                    NotificationService.Instance.Show("Zadanie zapisane w chmurze!");
                }
                else
                {
                    addTaskVm.CreatedTask.Id = _allTasks.Any() ? _allTasks.Max(t => t.Id) + 1 : 1;
                    _allTasks.Insert(0, addTaskVm.CreatedTask);
                    ApplyFilters(); 
                    NotificationService.Instance.Show("Brak sieci. Zadanie zapisano lokalnie!");
                }
            }
        }

        [RelayCommand(CanExecute = nameof(CanEditTask))]
        public async Task EditTask()
        {
            if (SelectedTask == null) return;

            var editTaskVm = new AddTaskViewModel();
            editTaskVm.AvailableUsernames = this.AvailableUsernames;
            editTaskVm.ApiUsers = this._apiUsers;

            editTaskVm.Title = SelectedTask.Title;
            editTaskVm.Description = SelectedTask.Description;
            editTaskVm.AssignedUser = SelectedTask.AssignedUser;
            editTaskVm.Status = SelectedTask.DisplayStatus;
            editTaskVm.DueDate = SelectedTask.DueDate;
            
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
                    NotificationService.Instance.Show("Zadanie zaktualizowane pomyślnie!");
                }
                else
                {
                    NotificationService.Instance.Show("Błąd aktualizacji na serwerze!");
                }
            }
        }

        private bool CanEditTask()
        {
            return SelectedTask != null;
        }
        
        [RelayCommand]
        public void PrepareEditProject()
        {
            if (SelectedProject == null || SelectedProject.Id == 0)
            {
                NotificationService.Instance.Show("Wybierz projekt z tabeli (nie można edytować 'Wszystkich')!");
                return;
            }
            
            if (SelectedProject.Owner != null && SelectedProject.Owner.Username != CurrentUserName)
            {
                NotificationService.Instance.Show("Odmowa dostępu! Tylko właściciel może edytować ten projekt.");
                return;
            }

            NewProjectName = SelectedProject.Name;
            NewProjectDescription = SelectedProject.Description;
            ProjectFormTitle = $"Edytujesz: {SelectedProject.Name}";
            ProjectButtonText = "Zapisz zmiany";
            _editingProjectId = SelectedProject.Id;
        }

        [RelayCommand]
        public void CancelEditProject()
        {
            NewProjectName = string.Empty;
            NewProjectDescription = string.Empty;
            ProjectFormTitle = "Utwórz nowy projekt";
            ProjectButtonText = "Dodaj projekt";
            _editingProjectId = null;
        }

        [RelayCommand]
        public async Task AddProject()
        {
            if (string.IsNullOrWhiteSpace(NewProjectName))
            {
                NotificationService.Instance.Show("Podaj nazwę projektu!");
                return;
            }

            if (_editingProjectId.HasValue) 
            {
                var projectToUpdate = new ProjectModel
                {
                    Id = _editingProjectId.Value,
                    Name = NewProjectName,
                    Description = NewProjectDescription ?? ""
                };

                bool isSuccess = await ApiService.Instance.UpdateProjectAsync(projectToUpdate);
                if (isSuccess)
                {
                    NotificationService.Instance.Show("Zaktualizowano projekt!");
                    CancelEditProject(); 
                    await LoadProjectsFromApiAsync(); 
                }
                else
                {
                    NotificationService.Instance.Show("Błąd aktualizacji projektu na serwerze.");
                }
            }
            else 
            {
                var nowyProjekt = new ProjectModel
                {
                    Name = this.NewProjectName,
                    Description = this.NewProjectDescription ?? ""
                };

                bool isSuccess = await ApiService.Instance.CreateProjectAsync(nowyProjekt);
                if (isSuccess)
                {
                    NotificationService.Instance.Show("Utworzono nowy projekt!");
                    CancelEditProject(); 
                    await LoadProjectsFromApiAsync(); 
                }
                else
                {
                    NotificationService.Instance.Show("Błąd! Nie udało się utworzyć projektu.");
                }
            }
        }

        [RelayCommand]
        public async Task DeleteProject()
        {
            if (SelectedProject == null || SelectedProject.Id == 0)
            {
                NotificationService.Instance.Show("Wybierz projekt do usunięcia!");
                return;
            }
            
            if (SelectedProject.Owner != null && SelectedProject.Owner.Username != CurrentUserName)
            {
                NotificationService.Instance.Show("Odmowa dostępu! Tylko właściciel może usunąć ten projekt.");
                return;
            }

            bool isSuccess = await ApiService.Instance.DeleteProjectAsync(SelectedProject.Id);
            if (isSuccess)
            {
                NotificationService.Instance.Show("Usunięto projekt z chmury!");
                if (_editingProjectId == SelectedProject.Id) CancelEditProject();
                
                await LoadProjectsFromApiAsync();
                await LoadTasksAsync(); 
            }
            else
            {
                NotificationService.Instance.Show("Błąd: Serwer odrzucił usunięcie.");
            }
        }

        [ObservableProperty]
        private string? _currentUserName;

        [ObservableProperty]
        private string? _currentUserEmail;

        [ObservableProperty]
        private string? _newPassword;

        [RelayCommand]
        public async Task SaveProfile()
        {
            if (string.IsNullOrWhiteSpace(NewPassword))
            {
                NotificationService.Instance.Show("Wpisz nowe hasło, aby zapisać zmiany!");
                return;
            }

            var currentUser = _apiUsers.FirstOrDefault(u => u.Username == CurrentUserName);

            if (currentUser != null)
            {
                bool isSuccess = await ApiService.Instance.UpdateProfileAsync(currentUser.Id, NewPassword);

                if (isSuccess)
                {
                    NotificationService.Instance.Show("Hasło zostało pomyślnie zmienione w chmurze!");
                    NewPassword = string.Empty;
                }
                else
                {
                    NotificationService.Instance.Show("Błąd: Serwer odrzucił zmianę hasła.");
                }
            }
            else
            {
                NotificationService.Instance.Show("Błąd: Nie odnaleziono Twojego profilu w pobranej bazie.");
            }
        }

        [RelayCommand]
        public void Logout()
        {
            ApiService.Instance.Logout();

            var loginWindow = new Views.LoginView();
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
        
        [RelayCommand]
        public async Task AcceptInvitation(int invitationId)
        {
            var invitation = PendingInvitations.FirstOrDefault(i => i.Id == invitationId);
            if (invitation != null)
            {
                PendingInvitations.Remove(invitation);
            }

            bool success = await ApiService.Instance.AcceptInvitationAsync(invitationId);
            
            if (success)
            {
                NotificationService.Instance.Show("Zaakceptowano zaproszenie!");
                await LoadProjectsFromApiAsync();
            }
            else
            {
                await LoadProjectsFromApiAsync();
            }
        }

        [RelayCommand]
        public async Task RejectInvitation(int invitationId)
        {
            bool success = await ApiService.Instance.RejectInvitationAsync(invitationId);
            if (success)
            {
                var invitation = PendingInvitations.FirstOrDefault(i => i.Id == invitationId);
                if (invitation != null)
                {
                    PendingInvitations.Remove(invitation);
                }
                NotificationService.Instance.Show("Odrzucono zaproszenie.");
            }
            else
            {
                NotificationService.Instance.Show("Błąd: Nie udało się odrzucić zaproszenia.");
            }
        }

        public NotificationService Notifier => NotificationService.Instance;

        public void SetTasksForTesting(List<TaskModel> tasks)
        {
            _allTasks = tasks;
        }
    }
}