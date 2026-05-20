using desktopapp.ViewModels;
using System.Windows;

using System.Windows;

namespace desktopapp.Views 
{
    public partial class AddTaskWindow : Window
    {

        public AddTaskWindow(ViewModels.AddTaskViewModel viewModel)
        {
            InitializeComponent();


            this.DataContext = viewModel;


            viewModel.CloseAction = () => this.Close();
        }
    }
}