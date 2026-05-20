using desktopapp.Data;
using desktopapp.Models;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using Xunit;

namespace desktopapp.Tests
{
    public class DatabaseTests
    {
        private DbContextOptions<AppDbContext> _options;

        public DatabaseTests()
        {
            _options = new DbContextOptionsBuilder<AppDbContext>()
                .UseInMemoryDatabase(databaseName: System.Guid.NewGuid().ToString()) // Używamy unikalnej nazwy dla każdej instancji testu
                .Options;
        }

        [Fact]
        public async Task Can_Add_And_Get_Task()
        {
            // Arrange
            using (var context = new AppDbContext(_options))
            {
                var task = new TaskModel { Id = 1, Title = "Test Task", Description = "", Status = "todo" };
                context.Tasks.Add(task);
                await context.SaveChangesAsync();
            }

            // Act
            using (var context = new AppDbContext(_options))
            {
                var task = await context.Tasks.FirstOrDefaultAsync(t => t.Title == "Test Task");

                // Assert
                Assert.NotNull(task);
                Assert.Equal("Test Task", task.Title);
            }
        }

        [Fact]
        public async Task Can_Add_And_Get_Project()
        {
            // Arrange
            using (var context = new AppDbContext(_options))
            {
                var project = new ProjectModel { Id = 1, Name = "Test Project", Description = "" };
                context.Projects.Add(project);
                await context.SaveChangesAsync();
            }

            // Act
            using (var context = new AppDbContext(_options))
            {
                var project = await context.Projects.FirstOrDefaultAsync(p => p.Name == "Test Project");

                // Assert
                Assert.NotNull(project);
                Assert.Equal("Test Project", project.Name);
            }
        }

        [Fact]
        public async Task Can_Add_And_Get_User()
        {
            // Arrange
            using (var context = new AppDbContext(_options))
            {
                var user = new UserModel { Id = 1, Username = "TestUser", Email = "test@test.com" };
                context.Users.Add(user);
                await context.SaveChangesAsync();
            }

            // Act
            using (var context = new AppDbContext(_options))
            {
                var user = await context.Users.FirstOrDefaultAsync(u => u.Username == "TestUser");

                // Assert
                Assert.NotNull(user);
                Assert.Equal("TestUser", user.Username);
            }
        }
    }
}