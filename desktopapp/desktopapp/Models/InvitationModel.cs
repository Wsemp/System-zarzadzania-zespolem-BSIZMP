using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

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
        public int InviterId { get; set; }
        
        [JsonProperty("project")]
        public int ProjectId { get; set; }
        
        [JsonProperty("project_name")]
        public string? ProjectName { get; set; }

        [JsonProperty("inviter_username")]
        public string? InviterUsername { get; set; }

        [JsonProperty("message")]
        public string? Message { get; set; }

        [JsonProperty("created_at")]
        public System.DateTime CreatedAt { get; set; }
        
        [JsonProperty("expires_at")]
        public System.DateTime? ExpiresAt { get; set; }

        [JsonProperty("accepted")]
        public bool Accepted { get; set; }
        
        public string DisplayProject => !string.IsNullOrEmpty(ProjectName) ? ProjectName : "Nieznany Projekt";
        
        public string DisplayInviter => !string.IsNullOrEmpty(InviterUsername) ? InviterUsername : "Nieznany Zapraszający";
    }
}