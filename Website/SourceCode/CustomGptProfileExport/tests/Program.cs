using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using CustomGptProfileExport.Models;
using CustomGptProfileExport.Services;

namespace CustomGptProfileExport.Tests
{
    /// <summary>
    /// Lightweight adjacent test runner. Keeping these tests in-module makes the
    /// exporter easier to review without pulling in the repo's broader test setup.
    /// </summary>
    public static class Program
    {
        public static int Main()
        {
            try
            {
                RenderProfile_IncludesOnlyNonEmptySections();
                RenderProfile_NormalizesHtmlAndKeywords();
                ShardWriter_WritesRandomizedShardsWithoutDroppingProfiles();
                ExportOptions_ParsesScopeAndIncludesItInFilters();
                Console.WriteLine("All CustomGptProfileExport tests passed.");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return 1;
            }
        }

        private static void RenderProfile_IncludesOnlyNonEmptySections()
        {
            var renderer = new ProfileTextRenderer();
            var profile = new ExportProfile
            {
                PersonId = 1,
                Name = "Jane Doe",
                Department = "Medicine",
                ProfilesUrl = "https://profiles.example.edu/jane.doe"
            };
            profile.RecentPublications.Add(new ExportPublication { Title = "Interesting Work", Year = 2024 });

            var text = renderer.RenderProfile(profile);
            AssertContains(text, "Name: Jane Doe");
            AssertContains(text, "Department: Medicine");
            AssertContains(text, "Profiles URL: https://profiles.example.edu/jane.doe");
            AssertContains(text, "Recent Publications:");
            AssertDoesNotContain(text, "Research Overview:");
            AssertDoesNotContain(text, "Keywords and Clinical Areas:");
        }

        private static void RenderProfile_NormalizesHtmlAndKeywords()
        {
            var renderer = new ProfileTextRenderer();
            var profile = new ExportProfile
            {
                PersonId = 2,
                Name = "Alex Smith",
                Department = "Neurology",
                Title = "Professor",
                ResearchOverview = "<p>Focuses on&nbsp;brain injury.</p>\r\n\r\n<div>Leads a lab</div>"
            };
            profile.Keywords.Add("Neurotrauma");
            profile.Keywords.Add("Brain Injury");

            var text = renderer.RenderProfile(profile);
            AssertContains(text, "Research Overview:");
            AssertContains(text, "Focuses on brain injury.");
            AssertContains(text, "Leads a lab");
            AssertContains(text, "- Neurotrauma");
            AssertContains(text, "- Brain Injury");
            AssertDoesNotContain(text, "<p>");
        }

        private static void ShardWriter_WritesRandomizedShardsWithoutDroppingProfiles()
        {
            var tempDirectory = Path.Combine(Path.GetTempPath(), "custom-gpt-export-tests-" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(tempDirectory);

            try
            {
                var renderer = new ProfileTextRenderer();
                var writer = new ShardWriter(renderer);
                var profiles = new List<ExportProfile>
                {
                    new ExportProfile { PersonId = 9, Name = "Charlie", Department = "A" },
                    new ExportProfile { PersonId = 4, Name = "Alice", Department = "A" },
                    new ExportProfile { PersonId = 7, Name = "Bob", Department = "A" }
                };

                var options = ExportOptions.Parse(new[]
                {
                    "--output-dir", tempDirectory,
                    "--shards", "2"
                });

                var files = writer.WriteShards(profiles, options);
                AssertEqual(2, files.Count, "Expected 2 shard files.");

                var shard1 = File.ReadAllText(Path.Combine(tempDirectory, "profiles_batch_01.txt"));
                var shard2 = File.ReadAllText(Path.Combine(tempDirectory, "profiles_batch_02.txt"));
                var combined = shard1 + shard2;
                AssertContains(combined, "Alice");
                AssertContains(combined, "Bob");
                AssertContains(combined, "Charlie");
                AssertEqual(3, CountOccurrences(combined, "=== PROFILE START ==="), "Expected one exported block per profile.");
            }
            finally
            {
                if (Directory.Exists(tempDirectory))
                {
                    Directory.Delete(tempDirectory, true);
                }
            }
        }

        private static void ExportOptions_ParsesScopeAndIncludesItInFilters()
        {
            var options = ExportOptions.Parse(new[]
            {
                "--output-dir", Path.GetTempPath(),
                "--scope", "faculty"
            });

            AssertTrue(options.Scope == ExportScope.Faculty, "Expected faculty scope.");
            AssertContains(options.DescribeFilters(), "scope=faculty");
        }

        private static void AssertContains(string text, string expected)
        {
            if (text.IndexOf(expected, StringComparison.Ordinal) < 0)
            {
                throw new InvalidOperationException("Expected to find: " + expected + Environment.NewLine + "Actual text:" + Environment.NewLine + text);
            }
        }

        private static void AssertDoesNotContain(string text, string unexpected)
        {
            if (text.IndexOf(unexpected, StringComparison.Ordinal) >= 0)
            {
                throw new InvalidOperationException("Did not expect to find: " + unexpected + Environment.NewLine + "Actual text:" + Environment.NewLine + text);
            }
        }

        private static void AssertEqual(int expected, int actual, string message)
        {
            if (expected != actual)
            {
                throw new InvalidOperationException(message + " Expected=" + expected + " Actual=" + actual);
            }
        }

        private static void AssertTrue(bool condition, string message)
        {
            if (!condition)
            {
                throw new InvalidOperationException(message);
            }
        }

        private static int CountOccurrences(string text, string value)
        {
            var count = 0;
            var index = 0;
            while ((index = text.IndexOf(value, index, StringComparison.Ordinal)) >= 0)
            {
                count++;
                index += value.Length;
            }

            return count;
        }
    }
}
