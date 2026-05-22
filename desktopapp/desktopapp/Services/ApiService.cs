using desktopapp.Data;
using desktopapp.Models;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace desktopapp.Services
{
    public class ApiService
    {
        private static ApiService _instance;
        public static ApiService Instance => _instance ??= new ApiService();

        private readonly HttpClient _client;
        private readonly AppDbContext _dbContext;
        private readonly string _baseUrl = "https://system-zarzadzania-zespolem-bsizmp.onrender.com/";

        public string? AccessToken { get; private set; }
        public string? LoggedInUsername { get; private set; }

        private ApiService() : this(new HttpClient(), new AppDbContext()) { }

        public ApiService(HttpClient client, AppDbContext? context = null)
        {
            _client = client;
            _dbContext = context ?? new AppDbContext();
        }

        private string ComputeHash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                return BitConverter.ToString(bytes).Replace("-", "").ToLower();
            }
        }

        public async Task<bool> LoginAsync(string username, string password)
        {
            var loginData = new { username, password };
            var json = JsonConvert.SerializeObject(loginData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _client.PostAsync(_baseUrl + "api/auth/login/", content);
                if (response.IsSuccessStatusCode)
                {
                    var responseString = await response.Content.ReadAsStringAsync();
                    var tokenData = JObject.Parse(responseString);
                    AccessToken = tokenData["access"]?.ToString();
                    _client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", AccessToken);

                    _dbContext.UserCredentials.RemoveRange(_dbContext.UserCredentials);
                    _dbContext.UserCredentials.Add(new UserCredential { Username = username, PasswordHash = ComputeHash(password) });
                    await _dbContext.SaveChangesAsync();
                    
                    LoggedInUsername = username;
                    return true;
                }
                return false;
            }
            catch
            {
                var savedCreds = await _dbContext.UserCredentials.FirstOrDefaultAsync();
                if (savedCreds != null && savedCreds.Username == username && savedCreds.PasswordHash == ComputeHash(password))
                {
                    LoggedInUsername = username;
                    return true;
                }
                return false;
            }
        }

        public void Logout()
        {
            AccessToken = null;
            _client.DefaultRequestHeaders.Authorization = null;
            _dbContext.UserCredentials.RemoveRange(_dbContext.UserCredentials);
            _dbContext.SaveChanges();
        }

        public async Task<bool> RegisterAsync(string username, string email, string password)
        {
            var registerData = new { username, email, password };
            var json = JsonConvert.SerializeObject(registerData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            try
            {
                var response = await _client.PostAsync(_baseUrl + "api/auth/register/", content);
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }

        public async Task<List<UserModel>> GetUsersAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl + "api/users/");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var usersList = JToken.Parse(json).ToObject<List<UserModel>>();
                    if (usersList != null)
                    {
                        _dbContext.Users.RemoveRange(_dbContext.Users);
                        await _dbContext.Users.AddRangeAsync(usersList);
                        await _dbContext.SaveChangesAsync();
                        return usersList;
                    }
                }
            }
            catch { }
            
            return await _dbContext.Users.ToListAsync();
        }

        public async Task<List<TaskModel>> GetTasksAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl + "api/tasks/");
                if (response.IsSuccessStatusCode)
                {
                    string json = await response.Content.ReadAsStringAsync();
                    var jArray = JArray.Parse(json);
                    var tasks = new List<TaskModel>();
                    
                    foreach (var item in jArray)
                    {
                        var task = item.ToObject<TaskModel>();
                        string projectUrl = item["project"]?.ToString();
                        if (!string.IsNullOrWhiteSpace(projectUrl))
                        {
                            var parts = projectUrl.TrimEnd('/').Split('/');
                            if (int.TryParse(parts.Last(), out int pId))
                            {
                                task.ProjectId = pId;
                            }
                        }
                        tasks.Add(task);
                    }

                    _dbContext.Tasks.RemoveRange(_dbContext.Tasks);
                    await _dbContext.Tasks.AddRangeAsync(tasks);
                    await _dbContext.SaveChangesAsync();
                    return tasks;
                }
            }
            catch { }

            return await _dbContext.Tasks.ToListAsync();
        }

        public async Task<bool> CreateTaskAsync(TaskModel newTask)
        {
            
            try
            {
                if (string.IsNullOrEmpty(AccessToken)) return false;

                var jObject = JObject.FromObject(newTask);
                jObject.Remove("Id");
                if (string.IsNullOrEmpty(newTask.Priority)) 
                {
                    jObject["priority"] = "low";
                }

                if (newTask.ProjectId > 0)
                {
                    jObject["project"] = $"{_baseUrl.TrimEnd('/')}/api/projects/{newTask.ProjectId}/";
                }
                
                string currentStatus = newTask.Status?.Trim().ToLower();

                if (currentStatus == "do zrobienia" || currentStatus == "todo") jObject["status"] = "todo";
                else if (currentStatus == "w trakcie" || currentStatus == "in_progress" || currentStatus == "in progress") jObject["status"] = "In progress";
                else if (currentStatus == "zakończone" || currentStatus == "done") jObject["status"] = "done";
                else jObject["status"] = "todo"; 

                var content = new StringContent(jObject.ToString(), Encoding.UTF8, "application/json");
                var response = await _client.PostAsync(_baseUrl + "api/tasks/", content);

                if (!response.IsSuccessStatusCode)
                {
                    string error = await response.Content.ReadAsStringAsync();
                    MessageBox.Show($"Błąd tworzenia zadania:\n{error}", "Błąd serwera", MessageBoxButton.OK, MessageBoxImage.Error);
                    return false;
                }
                return true;
            }
            catch (Exception ex)
            {
                _dbContext.Tasks.Add(newTask);
                await _dbContext.SaveChangesAsync();
                MessageBox.Show($"Brak sieci, zapisano zadanie lokalnie.", "Tryb Offline", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }
        }

        public async Task<bool> UpdateTaskAsync(TaskModel updatedTask)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken)) return false;
                
                var jObject = JObject.FromObject(updatedTask);
                jObject.Remove("Id");
                if (string.IsNullOrEmpty(updatedTask.Priority)) 
                {
                    jObject["priority"] = "low";
                }

                if (updatedTask.ProjectId > 0)
                {
                    jObject["project"] = $"{_baseUrl.TrimEnd('/')}/api/projects/{updatedTask.ProjectId}/";
                }
                
                string currentStatus = updatedTask.Status?.Trim();
                if (currentStatus == "Do zrobienia" || currentStatus == "todo") jObject["status"] = "todo";
                else if (currentStatus == "W trakcie" || currentStatus == "In progress") jObject["status"] = "In progress";
                else if (currentStatus == "Zakończone" || currentStatus == "done") jObject["status"] = "done";

                var content = new StringContent(jObject.ToString(), Encoding.UTF8, "application/json");
                var request = new HttpRequestMessage(new HttpMethod("PATCH"), _baseUrl + $"api/tasks/{updatedTask.Id}/") { Content = content };
                var response = await _client.SendAsync(request);

                if (!response.IsSuccessStatusCode)
                {
                    string error = await response.Content.ReadAsStringAsync();
                    MessageBox.Show($"Błąd edycji zadania:\n{error}", "Błąd serwera", MessageBoxButton.OK, MessageBoxImage.Error);
                    return false;
                }
                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Błąd sieciowy przy edycji: {ex.Message}", "Błąd połączenia", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        public async Task<bool> DeleteTaskAsync(int taskId)
        {
            try
            {
                var response = await _client.DeleteAsync(_baseUrl + $"api/tasks/{taskId}/");
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }

        public async Task<bool> UpdateProfileAsync(int userId, string newPassword)
        {
            try
            {
                var updateData = new { password = newPassword };
                var content = new StringContent(JsonConvert.SerializeObject(updateData), Encoding.UTF8, "application/json");
                var request = new HttpRequestMessage(new HttpMethod("PATCH"), _baseUrl + $"api/users/{userId}/") { Content = content };
                var response = await _client.SendAsync(request);
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }

        public async Task<List<ProjectModel>> GetProjectsAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl + "api/projects/");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    
                    var projects = JsonConvert.DeserializeObject<List<ProjectModel>>(json);
                    if (projects != null)
                    {
                        _dbContext.Projects.RemoveRange(_dbContext.Projects);
                        await _dbContext.Projects.AddRangeAsync(projects);
                        await _dbContext.SaveChangesAsync();
                        return projects;
                    }
                }
            }
            catch { }

            return await _dbContext.Projects.ToListAsync();
        }

        public async Task<bool> CreateProjectAsync(ProjectModel newProject)
        {
            var payload = new { name = newProject.Name, description = newProject.Description ?? "" };
            var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");
            var response = await _client.PostAsync(_baseUrl + "api/projects/", content);
            return response.IsSuccessStatusCode;
        }

        public async Task<bool> UpdateProjectAsync(ProjectModel updatedProject)
        {
            var content = new StringContent(JsonConvert.SerializeObject(updatedProject), Encoding.UTF8, "application/json");
            var request = new HttpRequestMessage(new HttpMethod("PATCH"), _baseUrl + $"api/projects/{updatedProject.Id}/") { Content = content };
            var response = await _client.SendAsync(request);
            return response.IsSuccessStatusCode;
        }

        public async Task<bool> DeleteProjectAsync(int projectId) => (await _client.DeleteAsync(_baseUrl + $"api/projects/{projectId}/")).IsSuccessStatusCode;

        // 🔥 OTO BRAKUJĄCA METODA OD POWIADOMIEŃ 🔥
        public async Task<List<NotificationModel>> GetNotificationsAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl + "api/notifications/");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    return JsonConvert.DeserializeObject<List<NotificationModel>>(json) ?? new List<NotificationModel>();
                }
            }
            catch { }
            return new List<NotificationModel>();
        }

        public async Task<List<InvitationModel>> GetPendingInvitationsAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl + "api/invitations/");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var allInvitations = JsonConvert.DeserializeObject<List<InvitationModel>>(json) ?? new List<InvitationModel>();
                    
                    return allInvitations.Where(i => !i.Accepted).ToList();
                }
            }
            catch { }
            return new List<InvitationModel>();
        }

        public async Task<bool> AcceptInvitationAsync(int invitationId)
        {
            try
            {
                var content = new StringContent("{}", Encoding.UTF8, "application/json");
                var response = await _client.PostAsync(_baseUrl + $"api/invitations/{invitationId}/accept/", content);
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }

        public async Task<bool> RejectInvitationAsync(int invitationId)
        {
            try
            {
                var content = new StringContent("{}", Encoding.UTF8, "application/json");
                var response = await _client.PostAsync(_baseUrl + $"api/invitations/{invitationId}/reject/", content);
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }
    }
}