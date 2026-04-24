using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using CustomGptProfileExport.Models;
using CustomGptProfileExport.Sql;

namespace CustomGptProfileExport.Services
{
    /// <summary>
    /// Loads the normalized export model from SQL Server. This class deliberately
    /// performs the export in three passes:
    /// 1. core profile rows
    /// 2. keyword rows
    /// 3. publication rows
    /// That keeps each query reviewable and avoids one very wide joined result set.
    /// </summary>
    public sealed class ProfileRepository
    {
        private readonly DbConnectionFactory _connectionFactory;

        public ProfileRepository(DbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public List<ExportProfile> LoadProfiles(ExportOptions options)
        {
            using (var connection = _connectionFactory.OpenConnection())
            {
                var profiles = LoadCoreProfiles(connection, options);
                if (profiles.Count == 0)
                {
                    return profiles;
                }

                var profileById = profiles.ToDictionary(profile => profile.PersonId);
                // Hydrate collections separately so the export model stays simple
                // and each query can focus on one concern.
                LoadKeywords(connection, profileById);
                LoadRecentPublications(connection, profileById, options.PublicationsPerProfile);
                return profiles;
            }
        }

        private static List<ExportProfile> LoadCoreProfiles(SqlConnection connection, ExportOptions options)
        {
            var query = ProfileExportQueries.BuildProfileQuery(
                options.Limit.HasValue,
                options.Scope == ExportScope.Faculty);

            using (var command = new SqlCommand(query, connection))
            {
                command.CommandType = CommandType.Text;
                command.CommandTimeout = 300;

                if (options.Limit.HasValue)
                {
                    command.Parameters.Add("@Limit", SqlDbType.Int).Value = options.Limit.Value;
                }

                command.CommandText = query;

                using (var reader = command.ExecuteReader())
                {
                    var profiles = new List<ExportProfile>();
                    while (reader.Read())
                    {
                        profiles.Add(new ExportProfile
                        {
                            PersonId = reader.GetInt32(0),
                            Name = HtmlTextNormalizer.Coalesce(reader["Name"] as string, "[UNKNOWN NAME]"),
                            Department = HtmlTextNormalizer.Coalesce(reader["Department"] as string, "Unknown"),
                            Title = HtmlTextNormalizer.NormalizeSingleLine(reader["Title"] as string),
                            ProfilesUrl = HtmlTextNormalizer.NormalizeSingleLine(reader["ProfilesUrl"] as string),
                            ResearchOverview = HtmlTextNormalizer.Normalize(reader["ResearchOverview"] as string)
                        });
                    }

                    return profiles;
                }
            }
        }

        private static void LoadKeywords(SqlConnection connection, IDictionary<int, ExportProfile> profileById)
        {
            var query = ProfileExportQueries.BuildKeywordQuery();
            using (var command = new SqlCommand(query, connection))
            {
                command.CommandType = CommandType.Text;
                command.CommandTimeout = 300;
                ReplaceIntToken(command, ref query, "{PERSON_IDS}", "keywordPersonId", profileById.Keys);
                command.CommandText = query;

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var personId = reader.GetInt32(0);
                        ExportProfile profile;
                        if (!profileById.TryGetValue(personId, out profile))
                        {
                            continue;
                        }

                        var keyword = HtmlTextNormalizer.NormalizeSingleLine(reader["MeshHeader"] as string);
                        if (string.IsNullOrWhiteSpace(keyword))
                        {
                            continue;
                        }

                        if (!profile.Keywords.Any(existing => string.Equals(existing, keyword, StringComparison.OrdinalIgnoreCase)))
                        {
                            profile.Keywords.Add(keyword);
                        }
                    }
                }
            }
        }

        private static void LoadRecentPublications(SqlConnection connection, IDictionary<int, ExportProfile> profileById, int publicationsPerProfile)
        {
            var query = ProfileExportQueries.BuildPublicationQuery();
            using (var command = new SqlCommand(query, connection))
            {
                command.CommandType = CommandType.Text;
                command.CommandTimeout = 300;
                command.Parameters.Add("@PublicationsPerProfile", SqlDbType.Int).Value = publicationsPerProfile;
                ReplaceIntToken(command, ref query, "{PERSON_IDS}", "publicationPersonId", profileById.Keys);
                command.CommandText = query;

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var personId = reader.GetInt32(0);
                        ExportProfile profile;
                        if (!profileById.TryGetValue(personId, out profile))
                        {
                            continue;
                        }

                        var title = HtmlTextNormalizer.NormalizeSingleLine(reader["PublicationTitle"] as string);
                        if (string.IsNullOrWhiteSpace(title))
                        {
                            continue;
                        }

                        int? year = null;
                        if (reader["PublicationYear"] != DBNull.Value)
                        {
                            year = Convert.ToInt32(reader["PublicationYear"]);
                        }

                        profile.RecentPublications.Add(new ExportPublication
                        {
                            Title = title,
                            Year = year
                        });
                    }
                }
            }
        }

        private static void ReplaceIntToken(SqlCommand command, ref string sql, string token, string parameterPrefix, IEnumerable<int> values)
        {
            var parameterNames = new List<string>();
            var index = 0;
            foreach (var value in values)
            {
                // Expand the IN-list into individually parameterized values so the
                // exporter does not inject raw integer lists into SQL text.
                var parameterName = "@" + parameterPrefix + index++;
                command.Parameters.Add(parameterName, SqlDbType.Int).Value = value;
                parameterNames.Add(parameterName);
            }

            sql = sql.Replace(token, string.Join(", ", parameterNames));
        }
    }
}
