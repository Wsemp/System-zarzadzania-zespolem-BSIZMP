using desktopapp.Models;
using Xunit;

namespace desktopapp.Tests
{
    public class TaskModelTests
    {
        [Theory]
        [InlineData("todo", "Do zrobienia")]
        [InlineData("in_progress", "W trakcie")]
        [InlineData("done", "Zakończone")]
        [InlineData("unknown", "unknown")]
        public void DisplayStatus_Zwraca_Prawidlowa_Polska_Nazwe_Dla_Statusu(string apiStatus, string expectedDisplay)
        {
            var task = new TaskModel { Status = apiStatus };

            string actualDisplay = task.DisplayStatus;

            Assert.Equal(expectedDisplay, actualDisplay);
        }

        [Theory]
        [InlineData("Do zrobienia", "todo")]
        [InlineData("W trakcie", "in_progress")]
        [InlineData("Zakończone", "done")]
        [InlineData("Inny", "Inny")]
        public void DisplayStatus_Ustawia_Prawidlowy_Status_Api(string displayStatus, string expectedApiStatus)
        {
            var task = new TaskModel();

            task.DisplayStatus = displayStatus;

            Assert.Equal(expectedApiStatus, task.Status);
        }
    }
}