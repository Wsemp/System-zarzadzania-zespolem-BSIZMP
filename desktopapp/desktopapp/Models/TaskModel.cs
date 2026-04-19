using Newtonsoft.Json;

namespace desktopapp.Models
{
    public class TaskModel
    {
        [JsonProperty("tag_ids")]
        public System.Collections.Generic.List<int> TagIds { get; set; } = new System.Collections.Generic.List<int>();

        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("assigned_to")]
        public int? AssignedToId { get; set; }

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