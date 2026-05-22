using System.Windows;
using desktopapp.ViewModels;

namespace desktopapp.Views;

public partial class ForgotPasswordWindow : Window
{
    public ForgotPasswordWindow()
    {
        InitializeComponent();
        var vm = new ForgotPasswordViewModel();
        vm.CloseAction = () => this.Close();
        this.DataContext = vm;
    }
}