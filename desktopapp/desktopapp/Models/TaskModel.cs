namespace desktopapp.Models
{
    public class TaskModel
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Status { get; set; } 
        public string AssignedUser { get; set; }
    }
}