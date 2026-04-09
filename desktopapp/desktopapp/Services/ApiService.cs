using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace desktopapp.Services
{
    public class ApiService
    {
        private static ApiService _instance;
        public static ApiService Instance => _instance ??= new ApiService();

        private readonly HttpClient _client;

        private readonly string _baseUrl = "https://system-zarzadzania-zespolem-bsizmp.onrender.com/";

        private readonly string _offlineUsersFile = "offline_users_backup.json";
        private readonly string _offlineCredsFile = "offline_creds_backup.json";
        private readonly string _offlineTasksFile = "offline_tasks_backup.json";



        public string AccessToken { get; private set; }

        private ApiService()
        {
            _client = new HttpClient();
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
                var response = await _client.PostAsync(_baseUrl + "api/auth/login/", content);

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

                        if (savedCreds.username == username && savedCreds.passwordHash == ComputeHash(password))
                        {
                            System.Windows.MessageBox.Show("Brak połączenia z serwerem! Wymuszono logowanie awaryjne ", "Tryb Offline");
                            return true;
                        }
                        else
                        {
                            System.Windows.MessageBox.Show("Błąd autoryzacji offline. Podano błędny login lub hasło.", "Odmowa dostępu");
                            return false;
                        }
                    }
                    catch
                    {
                        return false;
                    }
                }
                return false;
            }
        }

        public void Logout()
        {
            AccessToken = null;
            _client.DefaultRequestHeaders.Authorization = null;
            if (File.Exists(_offlineCredsFile))
            {
                File.Delete(_offlineCredsFile);
            }
        }

        public async Task<bool> RegisterAsync(string username, string email, string password)
        {
            var registerData = new { username = username, email = email, password = password };
            var json = JsonConvert.SerializeObject(registerData);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _client.PostAsync(_baseUrl + "api/auth/register/", content);
                return response.IsSuccessStatusCode;
            }
            catch
            {
                return false;
            }
        }

        public async Task<System.Collections.Generic.List<Models.UserModel>> GetUsersAsync()
        {
            var emptyList = new System.Collections.Generic.List<Models.UserModel>();

            try
            {
                var response = await _client.GetAsync(_baseUrl + "api/users/");

                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var parsed = JToken.Parse(json);

                    System.Collections.Generic.List<Models.UserModel> usersList = null;

                    if (parsed is JArray array)
                    {
                        usersList = array.ToObject<System.Collections.Generic.List<Models.UserModel>>();
                    }
                    else if (parsed is JObject obj && obj["results"] != null)
                    {
                        usersList = obj["results"].ToObject<System.Collections.Generic.List<Models.UserModel>>();
                    }

                    if (usersList != null && usersList.Count > 0)
                    {
                        string backupJson = JsonConvert.SerializeObject(usersList);
                        File.WriteAllText(_offlineUsersFile, backupJson);
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
                        string backupJson = File.ReadAllText(_offlineUsersFile);
                        var offlineUsers = JsonConvert.DeserializeObject<System.Collections.Generic.List<Models.UserModel>>(backupJson);
                        return offlineUsers;
                    }
                    catch
                    {
                    }
                }
            }

            return emptyList;
        }

        public void SaveTasksOffline(System.Collections.Generic.List<Models.TaskModel> tasks)
        {
            string json = JsonConvert.SerializeObject(tasks);
            File.WriteAllText(_offlineTasksFile, json);
        }

        public System.Collections.Generic.List<Models.TaskModel> GetTasksOffline()
        {
            if (File.Exists(_offlineTasksFile))
            {
                try
                {
                    string json = File.ReadAllText(_offlineTasksFile);
                    return JsonConvert.DeserializeObject<System.Collections.Generic.List<Models.TaskModel>>(json) ?? new System.Collections.Generic.List<Models.TaskModel>();
                }
                catch { }
            }
            return new System.Collections.Generic.List<Models.TaskModel>();
        }
    }
}