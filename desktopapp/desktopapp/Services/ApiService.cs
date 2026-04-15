using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;

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

        public string AccessToken { get; private set; }

        private ApiService()
        {
            _client = new HttpClient();

            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);


            string myAppFolder = Path.Combine(desktopPath, "BSI_TEST_OFFLINE");

            if (!Directory.Exists(myAppFolder))
            {
                Directory.CreateDirectory(myAppFolder);
            }

            _offlineUsersFile = Path.Combine(myAppFolder, "offline_users_backup.json");
            _offlineCredsFile = Path.Combine(myAppFolder, "offline_creds_backup.json");
            _offlineTasksFile = Path.Combine(myAppFolder, "offline_tasks_backup.json");
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

                    return true;
                }
                return false;
            }
            catch
            {
                if (File.Exists(_offlineUsersFile) && File.Exists(_offlineCredsFile))
                {
                    try
                    {
                        string savedCredsJson = File.ReadAllText(_offlineCredsFile);
                        dynamic savedCreds = JsonConvert.DeserializeObject(savedCredsJson);
                        if (savedCreds.username == username && savedCreds.passwordHash == ComputeHash(password)) return true;
                    }
                    catch { }
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
                    var parsed = JToken.Parse(json);
                    List<Models.UserModel> usersList = null;
                    if (parsed is JArray array) usersList = array.ToObject<List<Models.UserModel>>();
                    else if (parsed is JObject obj && obj["results"] != null) usersList = obj["results"].ToObject<List<Models.UserModel>>();

                    if (usersList != null)
                    {
                        File.WriteAllText(_offlineUsersFile, JsonConvert.SerializeObject(usersList));
                        return usersList;
                    }
                }
            }
            catch
            {
                if (File.Exists(_offlineUsersFile))
                {
                    try
                    {
                        return JsonConvert.DeserializeObject<List<Models.UserModel>>(File.ReadAllText(_offlineUsersFile));
                    }
                    catch { }
                }
            }
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
                    var tasks = JsonConvert.DeserializeObject<List<Models.TaskModel>>(json);
                    if (tasks != null) SaveTasksOffline(tasks);
                    return tasks ?? new List<Models.TaskModel>();
                }
            }
            catch { }
            return GetTasksOffline();
        }

        public async Task<bool> CreateTaskAsync(Models.TaskModel newTask)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken))
                {
                    System.Windows.MessageBox.Show("Błąd: Nie jesteś zalogowany! Zaloguj się ponownie.");
                    return false;
                }

                int originalId = newTask.Id;
                newTask.Id = 0;

                string json = JsonConvert.SerializeObject(newTask, new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore });
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                string url = _baseUrl.TrimEnd('/') + "/api/tasks/";

                var response = await _client.PostAsync(url, content);

                if (!response.IsSuccessStatusCode)
                {
                    string errorBody = await response.Content.ReadAsStringAsync();
                    System.Windows.MessageBox.Show($"Serwer odrzucił zadanie.\nKod: {response.StatusCode}\nSzczegóły: {errorBody}");
                    newTask.Id = originalId;
                    return false;
                }
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Błąd połączenia: {ex.Message}");
                return false;
            }
        }


        public async Task<bool> UpdateProfileAsync(int userId, string newPassword)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken)) return false;


                var updateData = new { password = newPassword };
                string json = JsonConvert.SerializeObject(updateData);
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

                string url = _baseUrl.TrimEnd('/') + $"/api/users/{userId}/";

                var request = new HttpRequestMessage(new HttpMethod("PATCH"), url) { Content = content };
                var response = await _client.SendAsync(request);

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
                else
                {
                    string errorBody = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"Błąd aktualizacji profilu: {response.StatusCode} - {errorBody}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Błąd połączenia: {ex.Message}");
                return false;
            }
        }



        public void SaveTasksOffline(List<Models.TaskModel> tasks)
        {
            try { File.WriteAllText(_offlineTasksFile, JsonConvert.SerializeObject(tasks)); } catch { }
        }

        public List<Models.TaskModel> GetTasksOffline()
        {
            if (File.Exists(_offlineTasksFile))
            {
                try { return JsonConvert.DeserializeObject<List<Models.TaskModel>>(File.ReadAllText(_offlineTasksFile)); } catch { }
            }
            return new List<Models.TaskModel>();
        }

        public async Task<bool> DeleteTaskAsync(int taskId)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken))
                {
                    System.Windows.MessageBox.Show("Błąd: Nie jesteś zalogowany!");
                    return false;
                }

                string url = _baseUrl.TrimEnd('/') + $"/api/tasks/{taskId}/";


                var response = await _client.DeleteAsync(url);


                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
                else
                {
                    string errorBody = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"Błąd usuwania zadania: {response.StatusCode} - {errorBody}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Błąd połączenia: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> UpdateTaskAsync(Models.TaskModel updatedTask)
        {
            try
            {
                if (string.IsNullOrEmpty(AccessToken)) return false;

                string json = JsonConvert.SerializeObject(updatedTask, new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore });
                var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

                string url = _baseUrl.TrimEnd('/') + $"/api/tasks/{updatedTask.Id}/";
                var response = await _client.PutAsync(url, content);

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
                else
                {
                    string errorBody = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"Błąd edycji: {response.StatusCode} - {errorBody}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Błąd połączenia: {ex.Message}");
                return false;
            }
        }
    }
}