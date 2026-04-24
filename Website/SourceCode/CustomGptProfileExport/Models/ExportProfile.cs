using System.Collections.Generic;

namespace CustomGptProfileExport.Models
{
    /// <summary>
    /// Normalized exporter model. The repository maps SQL rows into this shape and
    /// the renderer converts it into the final plain-text profile block.
    /// </summary>
    public sealed class ExportProfile
    {
        public int PersonId { get; set; }

        public string Name { get; set; }

        public string Department { get; set; }

        public string Title { get; set; }

        public string ProfilesUrl { get; set; }

        public string ResearchOverview { get; set; }

        public List<string> Keywords { get; } = new List<string>();

        public List<ExportPublication> RecentPublications { get; } = new List<ExportPublication>();
    }
}
