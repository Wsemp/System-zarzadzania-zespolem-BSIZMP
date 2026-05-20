using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace desktopapp.Models
{
    public class TaskModel
    {
        [Key]
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("project_id")]
        public int? ProjectId { get; set; }
        
        [NotMapped]
        [JsonProperty("tag_ids")]
        public System.Collections.Generic.List<int> TagIds { get; set; } = new System.Collections.Generic.List<int>();

        [JsonProperty("title")]
        public string? Title { get; set; }

        [JsonProperty("description")]
        public string? Description { get; set; }

        [JsonProperty("status")]
        public string? Status { get; set; }

        [JsonProperty("assigned_to")]
        public int? AssignedToId { get; set; }
        
        [JsonProperty("due_date")]
        public DateTime? DueDate { get; set; }

        [NotMapped]
        [JsonIgnore]
        public string? AssignedUser { get; set; }

        [NotMapped]
        [JsonIgnore]
        public string? DisplayStatus
        {
            get
            {
                if (string.Equals(Status, "todo", StringComparison.OrdinalIgnoreCase)) return "Do zrobienia";
                if (string.Equals(Status, "In progress", StringComparison.OrdinalIgnoreCase)) return "W trakcie";
                if (string.Equals(Status, "done", StringComparison.OrdinalIgnoreCase)) return "Zakończone";
                
                return Status; 
            }
            set
            {
                if (string.Equals(value, "Do zrobienia", StringComparison.OrdinalIgnoreCase)) Status = "todo";
                else if (string.Equals(value, "W trakcie", StringComparison.OrdinalIgnoreCase)) Status = "In progress";
                else if (string.Equals(value, "Zakończone", StringComparison.OrdinalIgnoreCase)) Status = "done";
                else Status = value;
            }
        }
    }
}