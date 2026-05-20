using desktopapp.Models;
using desktopapp.ViewModels;
using Moq;
using System.Collections.ObjectModel;
using Xunit;
using System.Linq;
using System.Collections.Generic;

namespace desktopapp.Tests
{
    public class MainViewModelTests
    {
        private MainViewModel _vm;
        private List<TaskModel> _allTasks;

        public MainViewModelTests()
        {
            _vm = new MainViewModel();
            _allTasks = new List<TaskModel>
            {
                new TaskModel { Id = 1, Title = "Task 1", ProjectId = 1, AssignedUser = "UserA" },
                new TaskModel { Id = 2, Title = "Task 2", ProjectId = 2, AssignedUser = "UserB" },
                new TaskModel { Id = 3, Title = "Task 3", ProjectId = 1, AssignedUser = "UserA" }
            };
            _vm.SetTasksForTesting(_allTasks);
        }

        [Fact]
        public void FilterByProject_Should_Return_Correct_Tasks()
        {
            // Arrange
            var project = new ProjectModel { Id = 1, Name = "Project 1" };
            _vm.SelectedProjectFilter = project;

            // Act
            _vm.ApplyFilters();

            // Assert
            Assert.Equal(2, _vm.Tasks.Count);
            Assert.True(_vm.Tasks.All(t => t.ProjectId == 1));
        }

        [Fact]
        public void FilterByUser_Should_Return_Correct_Tasks()
        {
            // Arrange
            _vm.SearchUserText = "UserB";

            // Act
            _vm.ApplyFilters();

            // Assert
            Assert.Single(_vm.Tasks);
            Assert.Equal("UserB", _vm.Tasks.First().AssignedUser);
        }

        [Fact]
        public void ShowOnlyMyTasks_Should_Return_Correct_Tasks()
        {
            // Arrange
            _vm.CurrentUserName = "UserA";
            _vm.ShowOnlyMyTasks = true;

            // Act
            _vm.ApplyFilters();

            // Assert
            Assert.Equal(2, _vm.Tasks.Count);
            Assert.True(_vm.Tasks.All(t => t.AssignedUser == "UserA"));
        }
    }
}