using System;
using System.Linq;
using CustomGptProfileExport.Services;

namespace CustomGptProfileExport
{
    /// <summary>
    /// Console entrypoint for the exporter. It keeps orchestration thin so the
    /// module's data access, rendering, and file output remain easy to review.
    /// </summary>
    public static class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                // Parse CLI input first so misconfiguration fails before any DB
                // connection or file writes happen.
                var options = ExportOptions.Parse(args);
                var connectionFactory = new DbConnectionFactory(options);
                var repository = new ProfileRepository(connectionFactory);
                var renderer = new ProfileTextRenderer();
                var shardWriter = new ShardWriter(renderer);

                // The repository returns fully-populated export models. The writer
                // then handles randomized sharding and file output.
                var profiles = repository.LoadProfiles(options);
                var writtenFiles = shardWriter.WriteShards(profiles, options);

                Console.WriteLine(
                    "Exported {0} profiles into {1} file(s) under {2}",
                    profiles.Count,
                    writtenFiles.Count,
                    options.OutputDirectory);
                Console.WriteLine("Filters: " + options.DescribeFilters());
                Console.WriteLine("Artifacts: " + string.Join(", ", writtenFiles.Select(System.IO.Path.GetFileName)));
                return 0;
            }
            catch (UsageException ex)
            {
                Console.Error.WriteLine(ex.Message);
                return 2;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return 1;
            }
        }
    }
}
