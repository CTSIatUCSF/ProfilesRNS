using System.Collections.Generic;
using System.Linq;
using System.Text;
using CustomGptProfileExport.Models;

namespace CustomGptProfileExport.Services
{
    /// <summary>
    /// Converts normalized export models into the plain-text format intended for
    /// Custom GPT knowledge uploads.
    /// </summary>
    public sealed class ProfileTextRenderer
    {
        public string RenderProfile(ExportProfile profile)
        {
            var lines = new List<string>
            {
                "=== PROFILE START ===",
                "Name: " + HtmlTextNormalizer.Coalesce(profile.Name, "[UNKNOWN NAME]"),
                "Department: " + HtmlTextNormalizer.Coalesce(profile.Department, "Unknown")
            };

            var title = HtmlTextNormalizer.NormalizeSingleLine(profile.Title);
            if (!string.IsNullOrWhiteSpace(title))
            {
                lines.Add("Title: " + title);
            }

            var profileUrl = HtmlTextNormalizer.NormalizeSingleLine(profile.ProfilesUrl);
            if (!string.IsNullOrWhiteSpace(profileUrl))
            {
                lines.Add("Profiles URL: " + profileUrl);
            }

            if (profile.RecentPublications.Count > 0)
            {
                lines.Add(string.Empty);
                lines.Add("Recent Publications:");
                lines.AddRange(profile.RecentPublications.Select(RenderPublication));
            }

            var overview = HtmlTextNormalizer.Normalize(profile.ResearchOverview);
            if (!string.IsNullOrWhiteSpace(overview))
            {
                lines.Add(string.Empty);
                lines.Add("Research Overview:");
                lines.Add(overview);
            }

            if (profile.Keywords.Count > 0)
            {
                lines.Add(string.Empty);
                lines.Add("Keywords and Clinical Areas:");
                lines.AddRange(profile.Keywords.Select(keyword => "- " + HtmlTextNormalizer.NormalizeSingleLine(keyword)));
            }

            lines.Add(string.Empty);
            lines.Add("=== PROFILE END ===");
            lines.Add(string.Empty);

            // Build the block explicitly instead of using Environment.NewLine so
            // the output stays stable across Windows and non-Windows review
            // environments.
            var builder = new StringBuilder();
            for (var i = 0; i < lines.Count; i++)
            {
                builder.Append(lines[i]);
                builder.Append('\n');
            }

            return builder.ToString();
        }

        private static string RenderPublication(ExportPublication publication)
        {
            var title = HtmlTextNormalizer.NormalizeSingleLine(publication.Title);
            if (publication.Year.HasValue)
            {
                return "- " + title + " (" + publication.Year.Value + ")";
            }

            return "- " + title;
        }
    }
}
