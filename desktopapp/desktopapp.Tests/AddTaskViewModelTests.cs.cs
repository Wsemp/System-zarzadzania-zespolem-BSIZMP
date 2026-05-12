using desktopapp.ViewModels;
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
    }
}