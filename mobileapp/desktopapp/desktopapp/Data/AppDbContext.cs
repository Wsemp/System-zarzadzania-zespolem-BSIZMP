using desktopapp.Models;
using Microsoft.EntityFrameworkCore;
using System;

namespace desktopapp.Data
{
    public class AppDbContext : DbContext
    {
        public DbSet<TaskModel> Tasks { get; set; }
        public DbSet<ProjectModel> Projects { get; set; }
        public DbSet<UserModel> Users { get; set; }
        public DbSet<UserCredential> UserCredentials { get; set; }

        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
        public AppDbContext() { }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlite("Data Source=TaskomatLocal.db");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<TaskModel>().Ignore(t => t.AssignedUser);
            modelBuilder.Entity<TaskModel>().Ignore(t => t.DisplayStatus);
            modelBuilder.Entity<TaskModel>().Ignore(t => t.TagIds);
        }
    }
}