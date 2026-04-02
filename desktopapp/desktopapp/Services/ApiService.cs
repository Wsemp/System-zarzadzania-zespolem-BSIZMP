using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
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
        public string AccessToken { get; private set; }

        private ApiService()
        {
            _client = new HttpClient();
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

                    return true;
                }
                return false;
            }
            catch
            {
                return false; 
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
            try
            {
               
                var response = await _client.GetAsync(_baseUrl + "api/users/");

                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    var parsed = JToken.Parse(json);

                    if (parsed is JArray array)
                    {
                        return array.ToObject<System.Collections.Generic.List<Models.UserModel>>();
                    }
                    else if (parsed is JObject obj && obj["results"] != null)
                    {
                        return obj["results"].ToObject<System.Collections.Generic.List<Models.UserModel>>();
                    }
                }
                return new System.Collections.Generic.List<Models.UserModel>();
            }
            catch
            {
                return new System.Collections.Generic.List<Models.UserModel>();
            }
        }
    }
}