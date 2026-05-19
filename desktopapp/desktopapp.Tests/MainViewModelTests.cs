using desktopapp.Models;
using desktopapp.ViewModels;
using Moq;
using System.Collections.ObjectModel;
using Xunit;

namespace desktopapp.Tests
{
    public class MainViewModelTests
    {
        [Fact]
        public void EditTaskCommand_CanExecute_ReturnsFalse_WhenNoTaskIsSelected()
        {
            // Arrange
            var vm = new MainViewModel();
            vm.SelectedTask = null;

            // Act
            var canExecute = vm.EditTaskCommand.CanExecute(null);

            // Assert
            Assert.False(canExecute);
        }

        [Fact]
        public void EditTaskCommand_CanExecute_ReturnsTrue_WhenTaskIsSelected()
        {
            // Arrange
            var vm = new MainViewModel();
            vm.SelectedTask = new TaskModel();

            // Act
            var canExecute = vm.EditTaskCommand.CanExecute(null);

            // Assert
            Assert.True(canExecute);
        }
    }
}