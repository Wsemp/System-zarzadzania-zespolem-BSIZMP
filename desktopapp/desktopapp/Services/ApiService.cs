using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Linq;

namespace desktopapp.Services
{
    public class ApiService
    {
        private static ApiService _instance;
        public static ApiService Instance => _instance ??= new ApiService();

        private readonly HttpClient _client;
        private readonly string _baseUrl = "https://system-zarzadzania-zespolem-bsizmp.onrender.com/";

        private readonly string _offlineUsersFile;
        private readonly string _offlineCredsFile;
        private readonly string _offlineTasksFile;
        private readonly string _offlineProjectsFile;

        public string AccessToken { get; private set; }
        public string LoggedInUsername { get; private set; }

        private ApiService()
        {
            _client = new HttpClient();
            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            string myAppFolder = Path.Combine(desktopPath, "BSI_TEST_OFFLINE");

            if (!Directory.Exists(myAppFolder)) Directory.CreateDirectory(myAppFolder);

            _offlineUsersFile = Path.Combine(myAppFolder, "offline_users_backup.json");
            _offlineCredsFile = Path.Combine(myAppFolder, "offline_creds_backup.json");
            _offlineTasksFile = Path.Combine(myAppFolder, "offline_tasks_backup.json");
            _offlineProjectsFile = Path.Combine(myAppFolder, "offline_projects_backup.json");
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
            var loginData = new { username = username, password = password };
            var json = JsonConvert.SerializeObject(loginData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _client.PostAsync(_baseUrl.TrimEnd('/') + "/api/auth/login/", content);
                if (response.IsSuccessStatusCode)
                {
                    var responseString = await response.Content.ReadAsStringAsync();
                    var tokenData = JObject.Parse(responseString);
                    AccessToken = tokenData["access"]?.ToString();
                    _client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", AccessToken);

                    var secureCreds = new { username = username, passwordHash = ComputeHash(password) };
                    File.WriteAllText(_offlineCredsFile, JsonConvert.SerializeObject(secureCreds));
                    LoggedInUsername = username;
                    return true;
                }
                return false;
            }
            catch
            {
                if (File.Exists(_offlineUsersFile) && File.Exists(_offlineCredsFile))
                {
                    string savedCredsJson = File.ReadAllText(_offlineCredsFile);
                    dynamic savedCreds = JsonConvert.DeserializeObject(savedCredsJson);
                    if (savedCreds.username == username && savedCreds.passwordHash == ComputeHash(password))
                    {
                        LoggedInUsername = username; 
                        return true;
                    }
                }
                return false;
            }
        }

        public void Logout()
        {
            AccessToken = null;
            _client.DefaultRequestHeaders.Authorization = null;
            if (File.Exists(_offlineCredsFile)) File.Delete(_offlineCredsFile);
        }

        public async Task<bool> RegisterAsync(string username, string email, string password)
        {
            var registerData = new { username = username, email = email, password = password };
            var json = JsonConvert.SerializeObject(registerData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            try
            {
                var response = await _client.PostAsync(_baseUrl.TrimEnd('/') + "/api/auth/register/", content);
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }

        public async Task<List<Models.UserModel>> GetUsersAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl.TrimEnd('/') + "/api/users/");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var usersList = JToken.Parse(json).ToObject<List<Models.UserModel>>();
                    File.WriteAllText(_offlineUsersFile, JsonConvert.SerializeObject(usersList));
                    return usersList;
                }
            }
            catch { }
            return new List<Models.UserModel>();
        }

        public async Task<List<Models.TaskModel>> GetTasksAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl.TrimEnd('/') + "/api/tasks/");
                if (response.IsSuccessStatusCode)
                {
                    string json = await response.Content.ReadAsStringAsync();
                    var jArray = JArray.Parse(json);
                    var tasks = new List<Models.TaskModel>();
                    
                    foreach (var item in jArray)
                    {
                        var task = item.ToObject<Models.TaskModel>();
                        string projectUrl = item["project"]?.ToString();
                        if (!string.IsNullOrWhiteSpace(projectUrl))
                        {
                            var parts = projectUrl.TrimEnd('/').Split('/');
                            if (int.TryParse(parts.Last(), out int pId)) task.ProjectId = pId;
                        }

                        // --- TŁUMACZ ODBIERANIA Z SERWERA ---
                        if (task.Status == "todo") task.DisplayStatus = "Do zrobienia";
                        // Uznajemy różne warianty Wiktora na wszelki wypadek
                        else if (task.Status == "In progress") task.DisplayStatus = "W trakcie";
                        else if (task.Status == "done") task.DisplayStatus = "Zakończone";
                        else task.DisplayStatus = task.Status; 
                        // ------------------------------------
                        
                        tasks.Add(task);
                    }
                    SaveTasksOffline(tasks);
                    return tasks;
                }
            }
            catch { }
            return GetTasksOffline();
        }

        public async Task<bool> CreateTaskAsync(Models.TaskModel newTask)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken)) return false;

                var jObject = JObject.FromObject(newTask);
                jObject.Remove("Id");

                if (newTask.ProjectId > 0)
                    jObject["project"] = $"{_baseUrl.TrimEnd('/')}/api/projects/{newTask.ProjectId}/";

                // --- TŁUMACZ WYSYŁANIA NA SERWER ---
                string status = newTask.DisplayStatus ?? newTask.Status;
                if (status == "Do zrobienia") jObject["status"] = "todo";
                else if (status == "W trakcie") jObject["status"] = "In progress"; 
                else if (status == "Zakończone") jObject["status"] = "done";
                // -----------------------------------

                var content = new StringContent(jObject.ToString(), Encoding.UTF8, "application/json");
                var response = await _client.PostAsync(_baseUrl.TrimEnd('/') + "/api/tasks/", content);

                if (!response.IsSuccessStatusCode)
                {
                    string error = await response.Content.ReadAsStringAsync();
                    System.Windows.MessageBox.Show($"Błąd tworzenia zadania:\n{error}");
                    return false;
                }
                return true;
            }
            catch { return false; }
        }

        public async Task<bool> UpdateTaskAsync(Models.TaskModel updatedTask)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken)) return false;

                var jObject = JObject.FromObject(updatedTask);
                
                if (updatedTask.ProjectId > 0)
                    jObject["project"] = $"{_baseUrl.TrimEnd('/')}/api/projects/{updatedTask.ProjectId}/";

                // --- TŁUMACZ WYSYŁANIA NA SERWER ---
                string status = updatedTask.DisplayStatus ?? updatedTask.Status;
                if (status == "Do zrobienia") jObject["status"] = "todo";
                else if (status == "W trakcie") jObject["status"] = "In progress"; 
                else if (status == "Zakończone") jObject["status"] = "done";
                // -----------------------------------

                var content = new StringContent(jObject.ToString(), Encoding.UTF8, "application/json");
                string url = _baseUrl.TrimEnd('/') + $"/api/tasks/{updatedTask.Id}/";
                
                var request = new HttpRequestMessage(new HttpMethod("PATCH"), url) { Content = content };
                var response = await _client.SendAsync(request);

                if (!response.IsSuccessStatusCode)
                {
                    string error = await response.Content.ReadAsStringAsync();
                    System.Windows.MessageBox.Show($"Błąd edycji zadania:\n{error}");
                    return false;
                }
                return true;
            }
            catch { return false; }
        }

        public async Task<bool> DeleteTaskAsync(int taskId)
        {
            try
            {
                var response = await _client.DeleteAsync(_baseUrl.TrimEnd('/') + $"/api/tasks/{taskId}/");
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
                var request = new HttpRequestMessage(new HttpMethod("PATCH"), _baseUrl.TrimEnd('/') + $"/api/users/{userId}/") { Content = content };
                var response = await _client.SendAsync(request);
                return response.IsSuccessStatusCode;
            }
            catch { return false; }
        }

        public void SaveTasksOffline(List<Models.TaskModel> tasks) => File.WriteAllText(_offlineTasksFile, JsonConvert.SerializeObject(tasks));
        public List<Models.TaskModel> GetTasksOffline() => File.Exists(_offlineTasksFile) ? JsonConvert.DeserializeObject<List<Models.TaskModel>>(File.ReadAllText(_offlineTasksFile)) : new List<Models.TaskModel>();

        public async Task<List<Models.ProjectModel>> GetProjectsAsync()
        {
            try
            {
                var response = await _client.GetAsync(_baseUrl.TrimEnd('/') + "/api/projects/");
                if (response.IsSuccessStatusCode)
                {
                    var projects = JsonConvert.DeserializeObject<List<Models.ProjectModel>>(await response.Content.ReadAsStringAsync());
                    File.WriteAllText(_offlineProjectsFile, JsonConvert.SerializeObject(projects));
                    return projects;
                }
            }
            catch { }
            return new List<Models.ProjectModel>();
        }

        public async Task<bool> CreateProjectAsync(Models.ProjectModel newProject)
        {
            var payload = new { name = newProject.Name, description = newProject.Description ?? "" };
            var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");
            var response = await _client.PostAsync(_baseUrl.TrimEnd('/') + "/api/projects/", content);
            return response.IsSuccessStatusCode;
        }

        public async Task<bool> UpdateProjectAsync(Models.ProjectModel updatedProject)
        {
            var content = new StringContent(JsonConvert.SerializeObject(updatedProject), Encoding.UTF8, "application/json");
            var request = new HttpRequestMessage(new HttpMethod("PATCH"), _baseUrl.TrimEnd('/') + $"/api/projects/{updatedProject.Id}/") { Content = content };
            var response = await _client.SendAsync(request);
            return response.IsSuccessStatusCode;
        }

        public async Task<bool> DeleteProjectAsync(int projectId) => (await _client.DeleteAsync(_baseUrl.TrimEnd('/') + $"/api/projects/{projectId}/")).IsSuccessStatusCode;
    }
}