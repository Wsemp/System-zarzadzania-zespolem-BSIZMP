using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace desktopapp.Models
{
    public class InvitationModel
    {
        [Key]
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("email")]
        public string? Email { get; set; }

        [JsonProperty("inviter")]
        public string? InviterUrl { get; set; }

        [JsonProperty("project")]
        public string? ProjectUrl { get; set; }

        [JsonProperty("message")]
        public string? Message { get; set; }

        [JsonProperty("created_at")]
        public System.DateTime CreatedAt { get; set; }

        [JsonProperty("accepted")]
        public bool Accepted { get; set; }

        // Właściwości pomocnicze do wyświetlania
        public string DisplayProject
        {
            get
            {
                if (string.IsNullOrEmpty(ProjectUrl)) return "Nieznany Projekt";
                var parts = ProjectUrl.TrimEnd('/').Split('/');
                return parts.LastOrDefault(p => !string.IsNullOrEmpty(p)) ?? "Nieznany Projekt";
            }
        }

        public string DisplayInviter
        {
            get
            {
                if (string.IsNullOrEmpty(InviterUrl)) return "Nieznany Zapraszający";
                var parts = InviterUrl.TrimEnd('/').Split('/');
                return parts.LastOrDefault(p => !string.IsNullOrEmpty(p)) ?? "Nieznany Zapraszający";
            }
        }
    }
}