using System;
using System.Net;
using System.Text.RegularExpressions;

namespace CustomGptProfileExport.Services
{
    /// <summary>
    /// Normalizes rich text and mixed whitespace from the Profiles data sources
    /// into stable plain text for Custom GPT knowledge files.
    /// </summary>
    public static class HtmlTextNormalizer
    {
        private static readonly Regex HtmlTagPattern = new Regex("<[^>]+>", RegexOptions.Compiled);
        private static readonly Regex InlineWhitespacePattern = new Regex("[ \\t\\f\\v]+", RegexOptions.Compiled);
        private static readonly Regex BlankLinePattern = new Regex("\\n{3,}", RegexOptions.Compiled);

        public static string Normalize(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            var normalized = WebUtility.HtmlDecode(value);
            normalized = normalized.Replace("\r\n", "\n").Replace('\r', '\n');
            // Narrative and publication fields can contain simple HTML copied from
            // the site. Strip tags rather than trying to preserve presentation.
            normalized = HtmlTagPattern.Replace(normalized, " ");
            normalized = InlineWhitespacePattern.Replace(normalized, " ");
            normalized = Regex.Replace(normalized, " *\\n *", "\n");
            normalized = BlankLinePattern.Replace(normalized, "\n\n");
            return normalized.Trim();
        }

        public static string NormalizeSingleLine(string value)
        {
            var normalized = Normalize(value);
            return normalized.Replace("\n", " ").Trim();
        }

        public static string Coalesce(params string[] values)
        {
            foreach (var value in values)
            {
                var normalized = Normalize(value);
                if (!string.IsNullOrWhiteSpace(normalized))
                {
                    return normalized;
                }
            }

            return string.Empty;
        }
    }
}
