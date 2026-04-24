using System.Text;

namespace CustomGptProfileExport.Sql
{
    /// <summary>
    /// Centralizes the SQL used by the exporter so the module can be reviewed
    /// without chasing ad hoc query strings through the rest of the codebase.
    /// </summary>
    public static class ProfileExportQueries
    {
        public static string BuildProfileQuery(bool hasLimit, bool facultyOnly)
        {
            var sql = new StringBuilder();
            sql.AppendLine("SELECT " + (hasLimit ? "TOP (@Limit) " : string.Empty) + "p.PersonID,");
            sql.AppendLine("       COALESCE(NULLIF(LTRIM(RTRIM(p.DisplayName)), ''),");
            sql.AppendLine("                NULLIF(LTRIM(RTRIM(p.FirstName + ' ' + p.LastName)), '')) AS Name,");
            sql.AppendLine("       COALESCE(NULLIF(LTRIM(RTRIM(aff.DepartmentName)), ''), NULLIF(LTRIM(RTRIM(p.DepartmentName)), ''), 'Unknown') AS Department,");
            sql.AppendLine("       COALESCE(NULLIF(LTRIM(RTRIM(aff.Title)), ''), NULLIF(LTRIM(RTRIM(aff.FacultyRank)), ''), NULLIF(LTRIM(RTRIM(p.FacultyRank)), '')) AS Title,");
            sql.AppendLine("       CASE");
            sql.AppendLine("           WHEN alias.AliasID IS NOT NULL AND alias.AliasType IS NOT NULL");
            sql.AppendLine("               THEN basePath.BasePath + '/Display/' + alias.AliasType + '/' + alias.AliasID");
            sql.AppendLine("           ELSE basePath.BasePath + '/Profile/' + CAST(nodeMap.NodeID AS VARCHAR(50))");
            sql.AppendLine("       END AS ProfilesUrl,");
            sql.AppendLine("       CASE");
            sql.AppendLine("           WHEN p.ShowNarrative = 'Y' AND (security.ViewSecurityGroup = -1 OR security.ViewSecurityGroup IS NULL)");
            sql.AppendLine("               THEN overviewNode.Value");
            sql.AppendLine("           ELSE NULL");
            sql.AppendLine("       END AS ResearchOverview");
            sql.AppendLine("FROM [Profile.Cache].[Person] p");
            sql.AppendLine("JOIN [RDF.Stage].InternalNodeMap nodeMap");
            sql.AppendLine("  ON nodeMap.InternalID = p.PersonID");
            sql.AppendLine(" AND nodeMap.InternalType = 'Person'");
            sql.AppendLine(" AND nodeMap.Class = 'http://xmlns.com/foaf/0.1/Person'");
            sql.AppendLine("CROSS APPLY (");
            sql.AppendLine("    SELECT CAST(Value AS VARCHAR(MAX)) AS BasePath");
            sql.AppendLine("    FROM [Framework.].Parameter");
            sql.AppendLine("    WHERE ParameterID = 'basePath'");
            sql.AppendLine(") basePath");
            sql.AppendLine("OUTER APPLY (");
            sql.AppendLine("    SELECT TOP 1 pa.Title, d.DepartmentName, fr.FacultyRank, pa.FacultyRankID");
            sql.AppendLine("    FROM [Profile.Data].[Person.Affiliation] pa");
            sql.AppendLine("    LEFT JOIN [Profile.Data].[Organization.Department] d");
            sql.AppendLine("      ON d.DepartmentID = pa.DepartmentID");
            sql.AppendLine("    LEFT JOIN [Profile.Data].[Person.FacultyRank] fr");
            sql.AppendLine("      ON fr.FacultyRankID = pa.FacultyRankID");
            sql.AppendLine("    WHERE pa.PersonID = p.PersonID");
            sql.AppendLine("      AND ISNULL(pa.IsActive, 1) = 1");
            sql.AppendLine("    ORDER BY CASE WHEN ISNULL(pa.IsPrimary, 0) = 1 THEN 0 ELSE 1 END,");
            sql.AppendLine("             ISNULL(pa.SortOrder, 2147483647),");
            sql.AppendLine("             pa.PersonAffiliationID");
            sql.AppendLine(") aff");
            sql.AppendLine("OUTER APPLY (");
            sql.AppendLine("    SELECT TOP 1 a.AliasType, a.AliasID");
            sql.AppendLine("    FROM [RDF.].Alias a");
            sql.AppendLine("    WHERE a.NodeID = nodeMap.NodeID");
            sql.AppendLine("      AND a.Preferred = 1");
            sql.AppendLine(") alias");
            sql.AppendLine("OUTER APPLY (");
            sql.AppendLine("    SELECT TOP 1 predicate.NodeID AS PredicateNodeID");
            sql.AppendLine("    FROM [RDF.].Node predicate");
            sql.AppendLine("    WHERE predicate.ValueHash = [RDF.].fnValueHash(NULL, NULL, 'http://vivoweb.org/ontology/core#overview')");
            sql.AppendLine(") overviewPredicate");
            sql.AppendLine("LEFT JOIN [RDF.Security].[NodeProperty] security");
            sql.AppendLine("  ON security.NodeID = nodeMap.NodeID");
            sql.AppendLine(" AND security.Property = overviewPredicate.PredicateNodeID");
            sql.AppendLine("LEFT JOIN [RDF.].Triple overviewTriple");
            sql.AppendLine("  ON overviewTriple.Subject = nodeMap.NodeID");
            sql.AppendLine(" AND overviewTriple.Predicate = overviewPredicate.PredicateNodeID");
            sql.AppendLine("LEFT JOIN [RDF.].Node overviewNode");
            sql.AppendLine("  ON overviewNode.NodeID = overviewTriple.Object");
            sql.AppendLine("WHERE ISNULL(p.IsActive, 0) = 1");
            if (facultyOnly)
            {
                // "Faculty" scope is intentionally tied to the repo's canonical
                // faculty-rank model instead of brittle free-text title matching.
                sql.AppendLine("  AND (aff.FacultyRankID IS NOT NULL OR NULLIF(LTRIM(RTRIM(p.FacultyRank)), '') IS NOT NULL)");
            }
            sql.AppendLine("ORDER BY COALESCE(NULLIF(LTRIM(RTRIM(p.DisplayName)), ''), NULLIF(LTRIM(RTRIM(p.LastName + ', ' + p.FirstName)), ''), CAST(p.PersonID AS VARCHAR(50))), p.PersonID;");
            return sql.ToString();
        }

        public static string BuildKeywordQuery()
        {
            return
@"WITH ranked_keywords AS (
    SELECT cmp.PersonID,
           cmp.MeshHeader,
           ROW_NUMBER() OVER (
               PARTITION BY cmp.PersonID
               ORDER BY cmp.Weight DESC, cmp.NumPubsThis DESC, cmp.MeshHeader ASC
           ) AS keyword_rank
    FROM [Profile.Cache].[Concept.Mesh.Person] cmp
    WHERE cmp.PersonID IN ({PERSON_IDS})
)
SELECT PersonID, MeshHeader
FROM ranked_keywords
WHERE keyword_rank <= 15
ORDER BY PersonID, keyword_rank;";
        }

        public static string BuildPublicationQuery()
        {
            return
@"WITH publication_rows AS (
    SELECT a.PersonID,
           COALESCE(
               NULLIF(LTRIM(RTRIM(pg.ArticleTitle)), ''),
               NULLIF(LTRIM(RTRIM(mg.ArticleTitle)), ''),
               NULLIF(LTRIM(RTRIM(mg.PubTitle)), ''),
               NULLIF(LTRIM(RTRIM(i.EntityName)), ''),
               NULLIF(LTRIM(RTRIM(i.Reference)), '')
           ) AS PublicationTitle,
           COALESCE(i.PubYear, YEAR(i.EntityDate)) AS PublicationYear,
           ROW_NUMBER() OVER (
               PARTITION BY a.PersonID
               ORDER BY
                   CASE WHEN i.EntityDate IS NULL THEN 1 ELSE 0 END,
                   i.EntityDate DESC,
                   i.EntityID DESC
           ) AS publication_rank
    FROM [Profile.Data].[Publication.Entity.Authorship] a
    JOIN [Profile.Data].[Publication.Entity.InformationResource] i
      ON i.EntityID = a.InformationResourceID
    LEFT JOIN [Profile.Data].[Publication.PubMed.General] pg
      ON pg.PMID = i.PMID
    LEFT JOIN [Profile.Data].[Publication.MyPub.General] mg
      ON mg.MPID = i.MPID
    WHERE a.IsActive = 1
      AND i.IsActive = 1
      AND a.PersonID IN ({PERSON_IDS})
)
SELECT PersonID, PublicationTitle, PublicationYear
FROM publication_rows
WHERE publication_rank <= @PublicationsPerProfile
  AND PublicationTitle IS NOT NULL
ORDER BY PersonID, publication_rank;";
        }
    }
}
