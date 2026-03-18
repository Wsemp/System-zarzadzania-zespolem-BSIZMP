using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace desktopapp.Services
{
    public class ApiService
    {
        private static ApiService _instance;
        public static ApiService Instance => _instance ??= new ApiService();

        private readonly HttpClient _client;

        private readonly string _baseUrl = "http://localhost:8000/api/";

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
                await Task.Delay(1000); 
                return username == "admin" && password == "1234";
            }
            catch
            {
                return false; 
            }
        }
    }
}