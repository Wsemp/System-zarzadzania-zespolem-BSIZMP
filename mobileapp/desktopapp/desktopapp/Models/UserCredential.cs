using System.ComponentModel.DataAnnotations;

namespace desktopapp.Models
{
    public class UserCredential
    {
        [Key]
        public int Id { get; set; }
        public string? Username { get; set; }
        public string? PasswordHash { get; set; }
    }
}