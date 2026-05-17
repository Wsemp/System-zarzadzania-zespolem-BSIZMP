using desktopapp.Data;
using System.Windows;

namespace desktopapp
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            using (var db = new AppDbContext())
            {
                db.Database.EnsureCreated();
            }
        }
    }
}