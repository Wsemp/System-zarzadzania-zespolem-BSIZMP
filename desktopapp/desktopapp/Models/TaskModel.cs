using Newtonsoft.Json;
using System;
using System.ComponentModel.DataAnnotations;

namespace desktopapp.Models
{
    public class TaskModel
    {
        [Key]
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("project_id")]
        public int? ProjectId { get; set; }
        
        [JsonProperty("tag_ids")]
        public System.Collections.Generic.List<int> TagIds { get; set; } = new System.Collections.Generic.List<int>();

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("assigned_to")]
        public int? AssignedToId { get; set; }
        
        [JsonProperty("due_date")]
        public DateTime? DueDate { get; set; }

        [JsonIgnore]
        public string AssignedUser { get; set; }

        [JsonIgnore]
        public string DisplayStatus
        {
            get
            {
                return Status switch
                {
                    "todo" => "Do zrobienia",
                    "in_progress" => "W trakcie",
                    "done" => "Zakończone",
                    _ => Status
                };
            }
            set
            {
                Status = value switch
                {
                    "Do zrobienia" => "todo",
                    "W trakcie" => "in_progress",
                    "Zakończone" => "done",
                    _ => value
                };
            }
        }
    }
}