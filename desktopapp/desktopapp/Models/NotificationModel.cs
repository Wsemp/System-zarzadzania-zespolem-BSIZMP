using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;

namespace desktopapp.Models
{
    public class NotificationModel
    {
        [Key]
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("message")]
        public string? Message { get; set; }

        [JsonProperty("created_at")]
        public DateTime CreatedAt { get; set; }

        [JsonProperty("is_read")]
        public bool IsRead { get; set; }
        
        [JsonProperty("type")]
        public string? Type { get; set; }
        
        [JsonIgnore]
        public string? TaskTitle { get; set; }
        
        [JsonProperty("task")]
        public string? TaskUrl { get; set; }
        
    }
}