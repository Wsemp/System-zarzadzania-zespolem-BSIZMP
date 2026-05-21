using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

namespace desktopapp.Models
{
    public class InvitationModel
    {
        [Key]
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("project_name")]
        public string? ProjectName { get; set; }

        [JsonProperty("invited_by")]
        public string? InvitedBy { get; set; }

        [JsonProperty("status")]
        public string? Status { get; set; }
    }
}