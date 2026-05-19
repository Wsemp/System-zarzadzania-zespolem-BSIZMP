using desktopapp.ViewModels;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Threading;

namespace desktopapp
{
    public partial class MainWindow : Window
    {
        private DispatcherTimer _idleTimer;

        public MainWindow()
        {
            InitializeComponent();
            InitializeIdleTimer();
            this.PreviewMouseMove += OnUserActivity;
            this.PreviewKeyDown += OnUserActivity;
        }

        private void InitializeIdleTimer()
        {
            _idleTimer = new DispatcherTimer();
            // Ustaw czas na 5 minut. Do testów można zmienić na np. TimeSpan.FromSeconds(10)
            _idleTimer.Interval = TimeSpan.FromMinutes(1);
            _idleTimer.Tick += IdleTimer_Tick;
            _idleTimer.Start();
        }

        private void IdleTimer_Tick(object sender, EventArgs e)
        {
            _idleTimer.Stop();
            if (this.DataContext is MainViewModel vm && vm.LogoutCommand.CanExecute(null))
            {
                vm.LogoutCommand.Execute(null);
            }
        }

        private void OnUserActivity(object sender, InputEventArgs e)
        {
            _idleTimer.Stop();
            _idleTimer.Start();
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