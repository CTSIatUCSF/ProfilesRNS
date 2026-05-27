using CsvHelper;
using Newtonsoft.Json.Linq;
using Profiles.Framework.Utilities;
using Profiles.ORCID.Utilities.ProfilesRNSDLL.BLL.ORCID;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web;

namespace Profiles.CustomAPI.Secure
{
    public partial class OAuthProxy : BrandedPage
    {
        private static Dictionary<OAuthRequest, OAuthToken> tokens = new Dictionary<OAuthRequest, OAuthToken>();

        protected void Page_Load(object sender, EventArgs e)
        {
            Profiles.CustomAPI.Utilities.DataIO data = new Profiles.CustomAPI.Utilities.DataIO();

            if (!data.IsAllowedSecureAccess(Request))
            {
                Response.ContentType = "text/plain";
                Response.Write("Access Denied");
                return;
            }

            var bodyStream = new StreamReader(Request.InputStream);
            bodyStream.BaseStream.Seek(0, SeekOrigin.Begin);
            var bodyText = bodyStream.ReadToEnd();

            OAuthRequest oreq = new OAuthRequest(Request["grant_type"], Request["client_id"], Request["client_secret"]);

            string tokenUrl = Request["token_url"];
            string dataUrl = Request["data_url"];

            try
            {
                OAuthToken token = GetToken(oreq, tokenUrl);
                using (var client = new System.Net.Http.HttpClient())
                {
                    var request = new System.Net.Http.HttpRequestMessage(System.Net.Http.HttpMethod.Get, dataUrl);
                    request.Headers.Add("Authorization", token.tokenType + " " + token.accessToken);
                    var response = client.SendAsync(request).Result;
                    if (response.IsSuccessStatusCode)
                    {
                        string json = response.Content.ReadAsStringAsync().Result;
                        Response.ContentType = "application/json";
                        Response.Write(json);
                    }
                    else
                    {
                        Response.ContentType = "text/plain";
                        Response.Write("Failed to get data: " + response.StatusCode);
                    }
                }
            }
            catch (Exception ex)
            {
                Response.ContentType = "text/plain";
                Response.Write("Error: " + ex.Message);
            }
        }

        private OAuthToken GetToken(OAuthRequest oreq, string tokenUrl)
        {
            if (tokens.TryGetValue(oreq, out OAuthToken token) && !token.IsAboutToExpire())
            {
                return token;
            }
            else
            {
                using (var client = new System.Net.Http.HttpClient())
                {
                    var request = new System.Net.Http.FormUrlEncodedContent(new Dictionary<string, string>
                    {
                        { "grant_type", oreq.grantType },
                        { "client_id", oreq.clientId },
                        { "client_secret", oreq.clientSecret }
                    });
                    var response = client.PostAsync(tokenUrl, request).Result;
                    if (response.IsSuccessStatusCode)
                    {
                        string json = response.Content.ReadAsStringAsync().Result;
                        JObject jsonObj = JObject.Parse(json);
                        token = new OAuthToken(jsonObj["access_token"].ToString(), jsonObj["token_type"].ToString(), Convert.ToInt32(jsonObj["expires_in"]));
                        //token = Newtonsoft.Json.JsonConvert.DeserializeObject<OAuthToken>(json);
                        tokens[oreq] = token;
                        return token;
                    }
                    else
                    {
                        throw new Exception("Failed to get token: " + response.StatusCode);
                    }
                }
            }
        }

        private class OAuthRequest
        {
            public OAuthRequest(string grantType, string clientId, string clientSecret)
            {
                this.grantType = grantType;
                this.clientId = clientId;
                this.clientSecret = clientSecret;
            }

            public string grantType { get; set; }
            public string clientId { get; set; }
            public string clientSecret { get; set; }

            public override bool Equals(object obj)
            {
                if (obj == null || !(obj is OAuthRequest))
                {
                    return false;
                }
                else
                {
                    OAuthRequest o = (OAuthRequest)obj;
                    return this.grantType == o.grantType && this.clientId == o.clientId && this.clientSecret == o.clientSecret;
                }
            }
            public override int GetHashCode()
            {
                return this.ToString().GetHashCode();
            }

            public override string ToString()
            {
                return this.grantType + ", " + this.clientId + ", " + this.clientSecret;
            }
        }

        private class OAuthToken
        {
            public OAuthToken(string accessToken, string tokenType, int expiresIn)
            {
                this.accessToken = accessToken;
                this.tokenType = tokenType;
                this.expiresIn = DateTime.Now.AddSeconds(expiresIn);
            }

            public string accessToken { get; set; }
            public string tokenType { get; set; }
            public DateTime expiresIn { get; set; }

            public bool IsAboutToExpire()
            {
                    return DateTime.Now >= expiresIn.AddSeconds(-3);
            }
        }
    }
}