using System;
using System.Configuration;
using System.Collections.Generic;
using System.IO;

namespace CustomGptProfileExport
{
    /// <summary>
    /// Export scope intentionally stays narrow. The user only asked for two
    /// operator modes: everyone, or the repo's canonical faculty population.
    /// </summary>
    public enum ExportScope
    {
        All,
        Faculty
    }

    /// <summary>
    /// Parsed command-line options for the exporter.
    /// </summary>
    public sealed class ExportOptions
    {
        private const string DefaultShardCountSetting = "DefaultShardCount";
        private const string DefaultPublicationCountSetting = "DefaultPublicationCount";
        private const string DefaultConnectionStringName = "ProfilesDataAPIDB";

        public string OutputDirectory { get; private set; }
        public int Shards { get; private set; }
        public int PublicationsPerProfile { get; private set; }
        public int? Limit { get; private set; }
        public bool Overwrite { get; private set; }
        public string ConnectionStringName { get; private set; }
        public string ConnectionString { get; private set; }
        public ExportScope Scope { get; private set; }

        private ExportOptions()
        {
        }

        public static ExportOptions Parse(string[] args)
        {
            if (args == null)
            {
                throw new ArgumentNullException("args");
            }

            var options = new ExportOptions
            {
                Shards = ReadIntAppSetting(DefaultShardCountSetting, 20),
                PublicationsPerProfile = ReadIntAppSetting(DefaultPublicationCountSetting, 10),
                ConnectionStringName = DefaultConnectionStringName,
                Scope = ExportScope.All
            };

            for (var i = 0; i < args.Length; i++)
            {
                var arg = args[i];
                switch (arg)
                {
                    case "--output-dir":
                        options.OutputDirectory = ReadRequiredValue(args, ref i, arg);
                        break;
                    case "--shards":
                        options.Shards = ReadPositiveInt(args, ref i, arg);
                        break;
                    case "--publications-per-profile":
                        options.PublicationsPerProfile = ReadNonNegativeInt(args, ref i, arg);
                        break;
                    case "--limit":
                        options.Limit = ReadPositiveInt(args, ref i, arg);
                        break;
                    case "--scope":
                        options.Scope = ReadScope(args, ref i, arg);
                        break;
                    case "--overwrite":
                        options.Overwrite = true;
                        break;
                    case "--connection-string-name":
                        options.ConnectionStringName = ReadRequiredValue(args, ref i, arg);
                        break;
                    case "--connection-string":
                        options.ConnectionString = ReadRequiredValue(args, ref i, arg);
                        break;
                    case "--help":
                    case "-h":
                    case "/?":
                        throw new UsageException(UsageText);
                    default:
                        throw new UsageException("Unknown argument: " + arg + Environment.NewLine + Environment.NewLine + UsageText);
                }
            }

            if (string.IsNullOrWhiteSpace(options.OutputDirectory))
            {
                throw new UsageException("--output-dir is required." + Environment.NewLine + Environment.NewLine + UsageText);
            }

            // Normalize the path once so downstream code can log and write using a
            // single stable value.
            options.OutputDirectory = Path.GetFullPath(options.OutputDirectory);
            return options;
        }

        public string DescribeFilters()
        {
            var parts = new List<string>();
            parts.Add("scope=" + (Scope == ExportScope.Faculty ? "faculty" : "all"));

            if (Limit.HasValue)
            {
                parts.Add("limit=" + Limit.Value);
            }

            return parts.Count == 0 ? "all active people" : string.Join(", ", parts);
        }

        public static string UsageText
        {
            get
            {
                return
@"Usage:
  CustomGptProfileExport.exe --output-dir <path> [options]

Options:
  --scope <all|faculty>           Export all active people, or only people with a canonical FacultyRank
  --shards <n>                    Number of shard files to emit (default: 20)
  --publications-per-profile <n>  Recent publications per profile (default: 10)
  --limit <n>                     Maximum number of profiles to export
  --overwrite                     Replace existing shard files in the output directory
  --connection-string-name <name> Connection string name from App.config (default: ProfilesDataAPIDB)
  --connection-string <value>     Explicit SQL Server connection string
  --help                          Show this message";
            }
        }

        private static int ReadIntAppSetting(string key, int fallbackValue)
        {
            int parsed;
            return int.TryParse(ConfigurationManager.AppSettings[key], out parsed) && parsed > 0
                ? parsed
                : fallbackValue;
        }

        private static int ReadPositiveInt(string[] args, ref int index, string arg)
        {
            var value = ReadRequiredValue(args, ref index, arg);
            int parsed;
            if (!int.TryParse(value, out parsed) || parsed < 1)
            {
                throw new UsageException(arg + " must be a positive integer.");
            }

            return parsed;
        }

        private static ExportScope ReadScope(string[] args, ref int index, string arg)
        {
            var value = ReadRequiredValue(args, ref index, arg);
            if ("all".Equals(value, StringComparison.OrdinalIgnoreCase))
            {
                return ExportScope.All;
            }

            if ("faculty".Equals(value, StringComparison.OrdinalIgnoreCase))
            {
                return ExportScope.Faculty;
            }

            throw new UsageException(arg + " must be either 'all' or 'faculty'.");
        }

        private static int ReadNonNegativeInt(string[] args, ref int index, string arg)
        {
            var value = ReadRequiredValue(args, ref index, arg);
            int parsed;
            if (!int.TryParse(value, out parsed) || parsed < 0)
            {
                throw new UsageException(arg + " must be a non-negative integer.");
            }

            return parsed;
        }

        private static string ReadRequiredValue(string[] args, ref int index, string arg)
        {
            if (index + 1 >= args.Length || args[index + 1].StartsWith("--", StringComparison.Ordinal))
            {
                throw new UsageException(arg + " requires a value.");
            }

            index++;
            return args[index];
        }
    }

    /// <summary>
    /// Signals argument/usage failures separately from runtime failures so the
    /// process can return a distinct exit code.
    /// </summary>
    public sealed class UsageException : Exception
    {
        public UsageException(string message)
            : base(message)
        {
        }
    }
}
