using System.Configuration;
using System.Data.SqlClient;

namespace CustomGptProfileExport.Services
{
    /// <summary>
    /// Resolves the SQL connection string from either explicit CLI input or the
    /// legacy App.config entry used by the surrounding system.
    /// </summary>
    public sealed class DbConnectionFactory
    {
        private readonly ExportOptions _options;

        public DbConnectionFactory(ExportOptions options)
        {
            _options = options;
        }

        public SqlConnection OpenConnection()
        {
            var connectionString = !string.IsNullOrWhiteSpace(_options.ConnectionString)
                ? _options.ConnectionString
                : ConfigurationManager.ConnectionStrings[_options.ConnectionStringName]?.ConnectionString;

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                throw new ConfigurationErrorsException(
                    "Could not resolve a SQL connection string. Use --connection-string or define " +
                    _options.ConnectionStringName + " in App.config.");
            }

            // The caller owns the returned open connection and disposes it with a
            // using-block.
            var connection = new SqlConnection(connectionString);
            connection.Open();
            return connection;
        }
    }
}
