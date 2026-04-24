using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using CustomGptProfileExport.Models;

namespace CustomGptProfileExport.Services
{
    /// <summary>
    /// Writes the rendered profile blocks into shard files.
    /// </summary>
    public sealed class ShardWriter
    {
        private readonly ProfileTextRenderer _renderer;

        public ShardWriter(ProfileTextRenderer renderer)
        {
            _renderer = renderer;
        }

        public IReadOnlyList<string> WriteShards(IReadOnlyList<ExportProfile> profiles, ExportOptions options)
        {
            Directory.CreateDirectory(options.OutputDirectory);
            EnsureWritableOutputDirectory(options);

            // Shuffle the profiles per run so the same people do not land in the
            // same upload batches every time the exporter is executed.
            var shuffledProfiles = profiles.ToList();
            Shuffle(shuffledProfiles);

            var writtenFiles = new List<string>();
            for (var shardIndex = 0; shardIndex < options.Shards; shardIndex++)
            {
                var shardPath = Path.Combine(
                    options.OutputDirectory,
                    string.Format(CultureInfo.InvariantCulture, "profiles_batch_{0:00}.txt", shardIndex + 1));

                // Integer partitioning keeps shard sizes balanced after the
                // randomized ordering step.
                var start = shardIndex * shuffledProfiles.Count / options.Shards;
                var end = (shardIndex + 1) * shuffledProfiles.Count / options.Shards;
                var builder = new StringBuilder();
                for (var i = start; i < end; i++)
                {
                    builder.Append(_renderer.RenderProfile(shuffledProfiles[i]));
                }

                File.WriteAllText(shardPath, builder.ToString(), new UTF8Encoding(false));
                writtenFiles.Add(shardPath);
            }

            return writtenFiles;
        }

        private static void EnsureWritableOutputDirectory(ExportOptions options)
        {
            if (options.Overwrite)
            {
                return;
            }

            var existingFiles = Directory.EnumerateFiles(options.OutputDirectory, "profiles_batch_*.txt").ToList();

            if (existingFiles.Count > 0)
            {
                throw new IOException(
                    "Output directory already contains export artifacts. Re-run with --overwrite or choose a clean directory.");
            }
        }

        private static void Shuffle<T>(IList<T> items)
        {
            var random = new Random(Guid.NewGuid().GetHashCode());
            for (var i = items.Count - 1; i > 0; i--)
            {
                var j = random.Next(i + 1);
                var item = items[i];
                items[i] = items[j];
                items[j] = item;
            }
        }
    }
}
