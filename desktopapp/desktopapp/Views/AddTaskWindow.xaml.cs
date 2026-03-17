using desktopapp.ViewModels;
using System.Windows;

namespace desktopapp.Views
{
    public partial class AddTaskWindow : Window
    {
        public AddTaskWindow(AddTaskViewModel viewModel)
        {
            InitializeComponent();
            DataContext = viewModel;

            viewModel.CloseAction = new System.Action(this.Close);
        }
    }
}