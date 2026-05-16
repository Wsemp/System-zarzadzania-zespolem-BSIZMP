using desktopapp.ViewModels;
using System.Windows;
using System.Windows.Controls;

namespace desktopapp
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void DataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {

        }

        private void NewPasswordBox_PasswordChanged(object sender, RoutedEventArgs e)
        {
            if (this.DataContext is MainViewModel vm)
            {
                vm.NewPassword = ((PasswordBox)sender).Password;
            }
        }
    }
}