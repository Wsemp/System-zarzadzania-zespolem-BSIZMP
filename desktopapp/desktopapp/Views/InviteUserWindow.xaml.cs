using System.Windows;
using desktopapp.ViewModels;

namespace desktopapp.Views
{
    public partial class InviteUserWindow : Window
    {
        public InviteUserWindow(int projectId, string projectName)
        {
            InitializeComponent();
            this.Title = $"Zaproś do projektu: {projectName}";

            var vm = new InviteUserViewModel();
            vm.ProjectId = projectId;
            vm.CloseAction = () => this.Close();
            
            this.DataContext = vm;
        }
    }
}