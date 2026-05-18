using desktopapp.ViewModels;
using desktopapp.Models;
using Xunit;

namespace desktopapp.Tests
{
    public class AddTaskViewModelTests
    {
        [Fact]
        public void Zapisz_Zadanie_Niemozliwe_Gdy_Puste_Pola()
        {
            var viewModel = new AddTaskViewModel();

            viewModel.Title = "";
            viewModel.AssignedUser = "";

            bool canSave = viewModel.SaveCommand.CanExecute(null);

            Assert.False(canSave);
        }

        [Fact]
        public void Zapisz_Zadanie_Mozliwe_Gdy_Pola_Wypelnione()
        {
            var viewModel = new AddTaskViewModel();

            viewModel.Title = "Zrobić pranie";
            viewModel.AssignedUser = "Kuba";

            bool canSave = viewModel.SaveCommand.CanExecute(null);

            Assert.True(canSave);
        }

        [Fact]
        public void Save_Assigns_Correct_ProjectId_To_CreatedTask()
        {
            // Arrange
            var viewModel = new AddTaskViewModel();
            var selectedProject = new ProjectModel { Id = 5, Name = "Test Project" };
            viewModel.SelectedProject = selectedProject;
            viewModel.Title = "New Task";
            viewModel.AssignedUser = "Test User";

            // Act
            viewModel.SaveCommand.Execute(null);

            // Assert
            Assert.NotNull(viewModel.CreatedTask);
            Assert.Equal(5, viewModel.CreatedTask.ProjectId);
        }
    }
}