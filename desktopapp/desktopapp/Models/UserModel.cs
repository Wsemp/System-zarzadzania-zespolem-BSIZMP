using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

namespace desktopapp.Models
{
    public class UserModel
    {
        [Key]
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("username")]
        public string? Username { get; set; }

        [JsonProperty("email")]
        public string? Email { get; set; }
    }
}