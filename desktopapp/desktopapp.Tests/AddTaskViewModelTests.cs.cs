using desktopapp.ViewModels;
using Xunit;

namespace desktopapp.Tests
{
    public class AddTaskViewModelTests
    {
        [Fact]
        public void Zapisz_Zadanie_Niemozliwe_Gdy_Puste_Pola()
        {
            // 1. ARRANGE (Przygotowanie) - Tworzymy formularz
            var viewModel = new AddTaskViewModel();

            // Symulujemy, że użytkownik zostawił puste pola
            viewModel.Title = "";
            viewModel.AssignedUser = "";

            // 2. ACT (Działanie) - Sprawdzamy, czy przycisk "Zapisz" pozwala na kliknięcie
            bool canSave = viewModel.SaveCommand.CanExecute(null);

            // 3. ASSERT (Sprawdzenie) - Oczekujemy, że wynik to FALSE (nie pozwala)
            Assert.False(canSave);
        }

        [Fact]
        public void Zapisz_Zadanie_Mozliwe_Gdy_Pola_Wypelnione()
        {
            // 1. ARRANGE
            var viewModel = new AddTaskViewModel();

            // Symulujemy, że użytkownik wpisał poprawne dane
            viewModel.Title = "Zrobić pranie";
            viewModel.AssignedUser = "Kuba";

            // 2. ACT
            bool canSave = viewModel.SaveCommand.CanExecute(null);

            // 3. ASSERT - Oczekujemy, że wynik to TRUE (pozwala na zapis)
            Assert.True(canSave);
        }
    }
}