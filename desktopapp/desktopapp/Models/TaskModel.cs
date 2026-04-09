using Newtonsoft.Json;

namespace desktopapp.Models
{
    public class TaskModel
    {
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
    }
}