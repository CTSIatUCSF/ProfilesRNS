namespace CustomGptProfileExport.Models
{
    /// <summary>
    /// Minimal publication model used for the "Recent Publications" export section.
    /// </summary>
    public sealed class ExportPublication
    {
        public string Title { get; set; }

        public int? Year { get; set; }
    }
}
