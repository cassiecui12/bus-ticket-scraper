using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System.Threading;
using OpenQA.Selenium.Support.UI;
using System.Globalization;

namespace TicketTracker
{
    public class DateTimeToStringConverter : IValueConverter
    {
        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return ((DateTime)value).ToString("dd/MM/yyyy");
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return DateTime.Parse(((string)value));
        }
    }

    public class ValidToImageConverter : IValueConverter
    {
        public object Convert(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            string valid = (string)value;
            string path = @"C:\Users\Cassie Cui\Desktop\Careers\Projects\.projects\Ticket Tracker\Icons\";
            if (valid == "-1") { return path + "Unchecked.png"; }
            if (valid == "0") { return path + "Invalid.png"; }
            if (valid == "1") { return path + "Valid.png"; }
            if (valid == "2") { return path + "Loading.png"; }
            return path + "Error.png";
        }

        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            return DateTime.Parse(((string)value));
        }
    }

    public class ValidDate
    {
        public string from { get; set; }
        public string to { get; set; }
        public DateTime date { get; set; }
        public string valid { get; set; }
        public string status { get; set; }
    }

    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {

        public bool initialized = false;
        public string from;
        public string to;
        public static string connectionString = "Data Source=.;Initial Catalog=BusDB;Integrated Security=True;Pooling=False";
        public static SqlConnection conn;
        public static SqlCommand cmd;
        public static SqlDataAdapter adapter;
        public static DataSet ds;
        public static SqlDataReader reader;
        public IList<ValidDate> co1;

        public Thread t1;
        public Thread t2;

        IWebDriver driver;
        WebDriverWait wait;





        public List<string> ComboBoxCitiesList { get; set; }

        public MainWindow()
        {
            InitializeComponent();


            var driverService = ChromeDriverService.CreateDefaultService();
            driverService.HideCommandPromptWindow = true;


            var chromeOptions = new ChromeOptions();
            chromeOptions.AddArguments("headless");

            driver = new ChromeDriver(driverService, chromeOptions);








            conn = new SqlConnection(connectionString);
            conn.Open();
            valid_dates_ReconfigureTable();
            conn.Close();

            InitializeComboBoxes("");
            LabelStatus.Content = "Status: Not Initialized";
            co1 = new List<ValidDate>();
            ListBoxDates.ItemsSource = co1;
            wait = new WebDriverWait(driver, TimeSpan.FromSeconds(20));

            CollectionView view = (CollectionView)CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource);
            view.Filter = UserFilter;

        }

        void InitializeComboBoxes(string text) 
        {
            ComboBoxCitiesList = new List<string>();
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                string query = "SELECT [stop_Name] FROM [dbo].[stops]";
                if (!string.IsNullOrEmpty(text)) { query += " WHERE [stop_name] LIKE '%{text}%'"; }
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ComboBoxCitiesList.Add( (string)reader.GetString(0) );
                        }
                    }
                }
            }
            ComboBoxFrom.ItemsSource = ComboBoxCitiesList;
            ComboBoxTo.ItemsSource = ComboBoxCitiesList;
        }
   
        static void valid_dates_ReconfigureTable()
        {
            string query = "DELETE FROM [dbo].[valid_dates] WHERE [date] < (SELECT CAST(GETDATE() AS DATE))";
            SqlCommand myCommand = new SqlCommand(query, conn);
            myCommand.ExecuteNonQuery();
            IDataRecord record;
            query = "SELECT * FROM [dbo].[trips]";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(query, connection);
                connection.Open();
                SqlDataReader reader = command.ExecuteReader();
                int day = 0;
                while (reader.Read())
                {
                    record = ((IDataRecord)reader);
                    bool[] days_of_the_week =
                        {
                        Convert.ToBoolean(record[2]),
                        Convert.ToBoolean(record[3]),
                        Convert.ToBoolean(record[4]),
                        Convert.ToBoolean(record[5]),
                        Convert.ToBoolean(record[6]),
                        Convert.ToBoolean(record[7]),
                        Convert.ToBoolean(record[8])
                    };

                    DateTime date = DateTime.Today.AddYears(1).AddDays(-1);
                    DateTime end = DateTime.Today;
                    bool runSql = true;
                    while (runSql && date >= end)
                    {
                        day = (int)date.DayOfWeek;
                        if (days_of_the_week[day])
                        {
                            SqlCommand check_User_Name = new SqlCommand(
                                $"SELECT * FROM[dbo].[valid_dates] " +
                                $"WHERE route_id = {record[0]} " +
                                $"AND date = '{date.ToString("yyyy-MM-dd")}'", conn);

                            bool rowExists = check_User_Name.ExecuteScalar() != null;
                            if (rowExists)
                            {
                                runSql = false;
                                break;
                            }
                            else
                            {
                                string new_query =
                                    $"INSERT INTO [dbo].[valid_dates] " +
                                    $"VALUES ({record[0]}, '{date.ToString("yyyy-MM-dd")}', NULL);";
                                myCommand = new SqlCommand(new_query, conn);
                                myCommand.ExecuteNonQuery();
                            }
                        }
                        date = date.AddDays(-1);
                    }
                }
                reader.Close();
            }
        }

        public bool UserFilter(object item) 
        {
            bool inSearch = (!string.IsNullOrEmpty((item as ValidDate).status));

            if (CheckBoxInvalidDates.IsChecked == true && CheckBoxNewDates.IsChecked == false)
            {
                return (inSearch || (item as ValidDate).valid == "-1" || (item as ValidDate).valid == "0" || (item as ValidDate).valid == "1");
            }
            else if (CheckBoxInvalidDates.IsChecked == false && CheckBoxNewDates.IsChecked == true)
            {
                return (inSearch || (item as ValidDate).valid == "-1");
            }
            else if (CheckBoxNewDates.IsChecked == false && CheckBoxNewDates.IsChecked == false)
            {
                return (inSearch || (item as ValidDate).valid == "-1" || (item as ValidDate).valid == "1");

            }
            
            return true;
        }

        public void menuItemClose_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Application.Current.Shutdown();
            return;
        }

        public void buttonGo_Click(object sender, RoutedEventArgs e)
        {
            from = ComboBoxFrom.Text;
            to = ComboBoxTo.Text;
            DataTable dt = CheckIfValid(from, to);
            if (dt.Rows.Count == 0) { MessageBox.Show($"Sorry, {from} - {to} is not a valid route!"); }
            else
            {
                if (t1 != null && t1.IsAlive) t1.Abort();
                if (t2 != null && t2.IsAlive) t2.Abort();
                ListBoxDates_Display2(dt);
                InitializeRoute();
            }
        }

        public DataTable CheckIfValid(string from, string to) 
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("usp_get_valid_dates", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@origin", SqlDbType.VarChar).Value = from;
                    cmd.Parameters.Add("@destination", SqlDbType.VarChar).Value = to;

                    conn.Open();
                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                    conn.Close();
                }
            }
            return dt;
        }

        static void ValidDates_InsertValidDate(string From, string To, string Date, string Valid)
        {
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                string query = $"IF EXISTS ( " +
                    $"SELECT * FROM [dbo].[ValidDates] " +
                    $"WHERE [From] = '{From}' " +
                    $"AND [To] = '{To}' " +
                    $"AND [Date] = '{Date}' " +
                    $") BEGIN " +
                    $"UPDATE [dbo].[ValidDates] " +
                    $"SET [Valid] = {Valid} " +
                    $"WHERE [From] = '{From}' " +
                    $"AND [To] = '{To}' " +
                    $"AND [Date] = '{Date}' " +
                    $"END " +
                    $"ELSE BEGIN " +
                    $"INSERT INTO [dbo].[ValidDates] ([From], [To], [Date], [Valid]) " +
                    $"VALUES ('{From}', '{To}', '{Date}', {Valid} ) " +
                    $"END;";
                SqlCommand myCommand = new SqlCommand(query, conn);
                myCommand.ExecuteNonQuery();
            }
            catch (Exception ex) { }
            finally { conn.Close(); }
        }

        static void valid_dates_Update(string Route_Id, string Date, string Valid)
        {
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                string query = $"IF EXISTS ( " +
                    $"SELECT * FROM [dbo].[valid_dates] " +
                    $"WHERE [route_id] = {Route_Id} " +
                    $"AND [date] = '{Date}' " +
                    $") BEGIN " +
                    $"UPDATE [dbo].[valid_dates] " +
                    $"SET [is_valid] = {Valid} " +
                    $"WHERE [route_id] = {Route_Id} " +
                    $"AND [date] = '{Date}' " +
                    $"END " +
                    $"ELSE BEGIN " +
                    $"INSERT INTO [dbo].[valid_dates] ([route_id], [date], [is_valid]) " +
                    $"VALUES ({Route_Id}, '{Date}', {Valid} ) " +
                    $"END;";
                SqlCommand myCommand = new SqlCommand(query, conn);
                myCommand.ExecuteNonQuery();
            }
            catch (Exception ex) { }
            finally { conn.Close(); }
        }

        static void Buses_RemoveDate(string from, string to, string date)
        {
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                string query = $"" +
                    $"DELETE FROM [dbo].[Buses] " +
                    $"WHERE [From] = '{from}' " +
                    $"AND [To] = '{to}' " +
                    $"AND [Departure] >= '{date}' " +
                    $"AND [Departure] < dateadd(day, 1, '{date}'";
                SqlCommand myCommand = new SqlCommand(query, conn);
                myCommand.ExecuteNonQuery();
            }
            catch (Exception ex) { }
            finally { conn.Close(); }
        }

        static void Buses_InsertValidTrip(string from, string to, string departure, string arrival, string transfers)
        {
            try
            {
                conn = new SqlConnection(connectionString);
                conn.Open();
                string query = $"INSERT INTO [dbo].[Buses] ([From], [To], [Departure], [Arrival], [Transfers]) " +
                    $"VALUES ('{from}', '{to}', '{departure}', '{arrival}', {transfers})";
                SqlCommand myCommand = new SqlCommand(query, conn);
                myCommand.ExecuteNonQuery();
            }
            catch (Exception ex) { }
            finally { conn.Close(); }
        }

        void ListBoxDates_Display2(DataTable dt)
        {
            co1 = new List<ValidDate>();
            foreach (DataRow dr in dt.Rows) 
            {
                string valid = "-1";
                if (!string.IsNullOrEmpty(dr["is_valid"].ToString()))
                    valid = dr["is_valid"].ToString();
                co1.Add(new ValidDate
                {
                    to = to,
                    from = from,
                    date = (DateTime)dr["date"],
                    valid = valid,
                    status = ""
                });
            }
            ListBoxDates.ItemsSource = co1;

            CollectionView view = (CollectionView)CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource);
            view.Filter = UserFilter;
        }

        void CheckBoxNewDates_Checked(object sender, EventArgs e)
        {
            CheckBoxInvalidDates.IsChecked = false;
            CheckBoxInvalidDates.IsEnabled = false;
            CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();
        }

        void CheckBoxNewDates_Unchecked(object sender, EventArgs e) 
        {
            CheckBoxInvalidDates.IsEnabled = true;
            CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();
        }

        void CheckBoxInvalidDates_Checked(object sender, EventArgs e) 
        {
            CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();
        }

        void CheckBoxInvalidDates_Unchecked(object sender, EventArgs e) 
        {
            CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();

        }

        void InitializeRoute() 
        {
            t1 = new Thread(() =>
            {
                Application.Current.Dispatcher.Invoke(() => { LabelStatus.Content = "Status: Initializing..."; });
                try
                {

                    driver.Url = "https://www.intercity.co.nz/";

                    IJavaScriptExecutor js = (IJavaScriptExecutor)driver;
                    IWebElement a = wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementToBeClickable(By.Id("BookTravelForm_getBookTravelForm_from")));
                    a.Click();
                    string value = (string)js.ExecuteScript($"document.getElementById('BookTravelForm_getBookTravelForm_from').setAttribute('value', '{from}')");
                    IWebElement b = wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementToBeClickable(By.Id("BookTravelForm_getBookTravelForm_to")));
                    b.Click();
                    string value2 = (string)js.ExecuteScript($"document.getElementById('BookTravelForm_getBookTravelForm_to').setAttribute('value', '{to}')");
                    a = wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementToBeClickable(By.Id("BookTravelForm_getBookTravelForm_from")));
                    a.Click();

                    string today = DateTime.Now.ToString("dd");

                    IWebElement d = wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementToBeClickable(By.XPath("//div[" +
                        $"((contains(text(), '{today}')) " +
                        "and not(contains(@class, 'invalid')))]")));


                    d.Click();

                    IWebElement e = wait.Until(SeleniumExtras.WaitHelpers.ExpectedConditions.ElementToBeClickable(By.Id("BookTravelForm_getBookTravelForm_action_submit")));
                    e.Click();
                    Application.Current.Dispatcher.Invoke(() => { LabelStatus.Content = "Status: Initialized"; });
                }
                catch (Exception ex)
                {
                    Application.Current.Dispatcher.Invoke(() =>
                    {
                        LabelStatus.Content = "Status: Not Initialized";
                        MessageBox.Show($"Sorry, something went wrong!");
                    });
                }
            });
            t1.Name = "InitializingThread";
            t1.Start();
        }

        string CheckDate(DateTime date)
        {
            Application.Current.Dispatcher.Invoke(() => { LabelStatus.Content = "Status: Searching..."; });
            string intercityDate = date.ToString("ddd, d MMM yyyy");
            Uri url = new Uri($"https://www.intercity.co.nz/book-a-trip/bookdepart?date={intercityDate}");
            driver.Navigate().GoToUrl(url);
            Thread.Sleep(5000);

            var prices = driver.FindElements(By.XPath("//div[contains(@class,'price')]/ancestor::form[contains(@method, 'post')]"));
            string valid = "0";
            Buses_RemoveDate(from, to, date.ToString("yyyy-MM-dd"));
            //REVERSE TO AVOID GOLD TICKET PROBLEMS
            foreach (var price in prices.Reverse())
            {

                var route_ids = price.FindElements(By.XPath(".//div[@class='service-number']"));

                string fare;
                try { fare = price.FindElement(By.XPath(".//div[@class='price']")).Text; }
                catch 
                {
                    fare = "SOLD OUT";
                    if (route_ids.Count == 1)
                    {
                        string why = route_ids[0].GetAttribute("outerHTML");
                        why = why.Substring(31, 4);
                        valid_dates_Update(why, date.ToString("yyyy-MM-dd"), "0");
                    }
                }
                var times = price.FindElements(By.XPath(".//div[@class='fare-time']"));
                if (fare == "$1.00" || fare == "$1")
                {
                    foreach (var route_id in route_ids) 
                    {
                        string why = route_id.GetAttribute("outerHTML");
                        why = why.Substring(31, 4);
                        valid_dates_Update(why, date.ToString("yyyy-MM-dd"), "1");
                    }
                    string departure = times[0].Text;
                    departure = DateTime.Parse(date.ToString("dd/MM/yyyy") + " " + departure).ToString("yyyy-MM-dd HH:mm:ss.000");
                    string arrival = times[1].Text;
                    arrival = DateTime.Parse(date.ToString("dd/MM/yyyy") + " " + arrival).ToString("yyyy-MM-dd HH:mm:ss.000");
                    string transfers = price.FindElement(By.XPath(".//p[@class='txt transfers']")).Text;
                    transfers = transfers == "Direct Service" ? "0" : transfers[0].ToString();
                    Buses_InsertValidTrip(from, to, departure, arrival, transfers);
                    valid = "1";
                }
                else 
                {
                    if (route_ids.Count == 1) 
                    {
                        string why = route_ids[0].GetAttribute("outerHTML");
                        why = why.Substring(31, 4);
                        valid_dates_Update(why, date.ToString("yyyy-MM-dd"), "0");
                    }
                }
                CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();
            }
            ValidDates_InsertValidDate(from, to, date.ToString("yyyy-MM-dd"), valid);
            Application.Current.Dispatcher.Invoke(() => { LabelStatus.Content = "Status: Initialized"; });
            return valid;
        }

        void ButtonSearch_Click(object sender, EventArgs e) 
        {

            if ((string)LabelStatus.Content == "Status: Initialized")
            {

                if (t1 != null && t1.IsAlive) t1.Abort();
                if (t2 != null && t2.IsAlive) t2.Abort();

                t2 = new Thread(() =>
                {
                    for (int i = 0; i < co1.Count; i++)
                    {
                        if (Application.Current.Dispatcher.Invoke(() => { return UserFilter(co1.ElementAt(i)); }))
                        {
                            co1[i].status = "loading";
                            co1[i].valid = "2";
                            Application.Current.Dispatcher.Invoke(() =>
                            {
                                ListBoxDates.ItemsSource = co1;
                                CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();
                            });


                            co1[i].valid = CheckDate(co1[i].date);
                            Application.Current.Dispatcher.Invoke(() =>
                            {
                                ListBoxDates.ItemsSource = co1;
                                CollectionViewSource.GetDefaultView(ListBoxDates.ItemsSource).Refresh();
                            });
                        }

                    }
                });
                t2.Name = "SearchingThread";
                t2.Start();
            }
            else if ((string)LabelStatus.Content == "Status: Searching...") { MessageBox.Show($"If you want to search again, please reinitialize this route!"); }
            else { MessageBox.Show($"You have not initialized a route!"); }
            /*

            foreach (ValidDate item in ListBoxDates.Items) 
            {
                CheckDate(item.date);

            }*/
        }
    }
}
