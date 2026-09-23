using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Profiles.Insights
{
    public partial class Default : BrandedPage
    {
        // Define your backend target server destination
        private static readonly string TargetServerUrl = "https://example.com";

        protected void Page_Load(object sender, EventArgs e)
        {
            HttpContext context = HttpContext.Current;

            // only let logged in users pass
            string idpServerVar = Request.ServerVariables["Shib-Identity-Provider"];

            if (String.IsNullOrEmpty(idpServerVar))
            {
                context.Response.StatusCode = Convert.ToInt16(HttpStatusCode.Unauthorized);
                return;
            }
            String inst = Institution.GetByShibbolethIdp(idpServerVar).GetAbbreviation();

            // 1. Reconstruct the destination URL with the original query string
            string queryString = context.Request.Url.Query;
            string targetUrl = TargetServerUrl + queryString;

            using (var client = new HttpClient())
            {
                // 2. Replicate the incoming HTTP Method (GET, POST, etc.)
                var method = new HttpMethod(context.Request.HttpMethod);
                using (var proxyRequest = new HttpRequestMessage(method, targetUrl))
                {
                    // 3. Copy incoming Request Headers (Skip restricted/managed headers)
                    foreach (string headerName in context.Request.Headers)
                    {
                        if (!HttpContentHeaders.IsContentHeader(headerName) &&
                            !headerName.Equals("Host", StringComparison.OrdinalIgnoreCase))
                        {
                            proxyRequest.Headers.TryAddWithoutValidation(headerName, context.Request.Headers[headerName]);
                        }
                    }

                    // 4. Forward the Request Body (For POST, PUT, PATCH)
                    if (method != HttpMethod.Get && context.Request.InputStream.Length > 0)
                    {
                        context.Request.InputStream.Position = 0;
                        proxyRequest.Content = new StreamContent(context.Request.InputStream);

                        // Copy Content-Type and other content-specific headers
                        foreach (string headerName in context.Request.Headers)
                        {
                            if (HttpContentHeaders.IsContentHeader(headerName))
                            {
                                proxyRequest.Content.Headers.TryAddWithoutValidation(headerName, context.Request.Headers[headerName]);
                            }
                        }
                    }

                    // 5. Send the request to the backend server
                    using (HttpResponseMessage proxyResponse = client.SendAsync(proxyRequest).Result)
                    {
                        // 6. Clear default ASP.NET response settings
                        context.Response.Clear();
                        context.Response.ClearHeaders();
                        context.Response.StatusCode = (int)proxyResponse.StatusCode;

                        // 7. Copy backend response headers to the client response
                        foreach (var header in proxyResponse.Headers)
                        {
                            context.Response.Headers.Add(header.Key, string.Join(",", header.Value));
                        }
                        foreach (var header in proxyResponse.Content.Headers)
                        {
                            context.Response.Headers.Add(header.Key, string.Join(",", header.Value));
                        }

                        // 8. Stream the backend body directly to the client response
                        string resp = proxyResponse.Content.ReadAsStringAsync().Result;
                        context.Response.Write(resp);


                        // Flush and terminate the response to prevent further processing
                        context.Response.Flush();
                        context.ApplicationInstance.CompleteRequest();
                    }
                }
            }
        }
    }

    // Helper class to identify content-specific HTTP headers
    internal static class HttpContentHeaders
    {
        private static readonly System.Collections.Generic.HashSet<string> ContentHeaders =
            new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "Allow", "Content-Disposition", "Content-Encoding", "Content-Language",
                "Content-Length", "Content-Location", "Content-MD5", "Content-Range",
                "Content-Type", "Expires", "Last-Modified"
            };

        public static bool IsContentHeader(string headerName)
        {
            return ContentHeaders.Contains(headerName);
        }
    }
}