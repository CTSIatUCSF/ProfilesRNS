using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;

namespace Profiles
{
    public class InsightsProxy : IHttpAsyncHandler 
    {
        // Reusing HttpClient instance is critical to avoid socket exhaustion.
        private static readonly HttpClient _httpClient = new HttpClient(new HttpClientHandler
        {
            AllowAutoRedirect = false, // Let the original client handle redirects
            UseCookies = false         // Let the original client handle cookies
        });

        // Define your backend target base URL
        private readonly string _targetBaseUrl = "https://insights-content.researcherprofiles.org/published-papers-propel-progress/";

        public bool IsReusable => true;

        // Boilerplate required for IHttpAsyncHandler
        public IAsyncResult BeginProcessRequest(HttpContext context, AsyncCallback cb, object extraData)
        {
            return TaskToApm(ProcessRequestAsync(context), cb, extraData);
        }

        public void EndProcessRequest(IAsyncResult result)
        {
            ((Task)result).GetAwaiter().GetResult();
        }

        public void ProcessRequest(HttpContext context)
        {
            // Fallback required by interface, but logic runs asynchronously
            throw new NotImplementedException("Use async pipeline instead.");
        }

        private async Task ProcessRequestAsync(HttpContext context)
        {
            var request = context.Request;
            var response = context.Response;

            // 1. Build the target URI string 
            string idpServerVar = request.ServerVariables["Shib-Identity-Provider"];
            String inst = Institution.GetByShibbolethIdp(idpServerVar).GetAbbreviation().ToLower();

            //string relativePath = request.AppRelativeCurrentExecutionFilePath.Replace("~", "").Replace("/insights", "");
            //string targetUrl = $"{_targetBaseUrl}{inst}{relativePath}{request.Url.Query}";
            string targetUrl = request.Url.AbsoluteUri.Replace(request.Url.Scheme + "://" + request.Url.Host + "/insights", _targetBaseUrl + inst);


            // 2. Initialize outbound HttpRequestMessage
            var method = new HttpMethod(request.HttpMethod);
            using (var proxyRequest = new HttpRequestMessage(method, targetUrl))
            {
                // 3. Copy client request body if available
                if (request.TotalBytes > 0 && (method == HttpMethod.Post || method == HttpMethod.Put))
                {
                    proxyRequest.Content = new StreamContent(request.InputStream);
                }

                // 4. Copy incoming request headers to outbound message
                CopyHeadersToProxyRequest(request, proxyRequest);

                try
                {
                    // 5. Send request to target server
                    using (var proxyResponse = await _httpClient.SendAsync(proxyRequest, HttpCompletionOption.ResponseHeadersRead))
                    {
                        // 6. Copy target status and headers back to client
                        response.StatusCode = (int)proxyResponse.StatusCode;
                        response.StatusDescription = proxyResponse.ReasonPhrase;

                        CopyHeadersToClientResponse(proxyResponse, response);

                        // 7. Stream content backend directly to client response stream
                        await proxyResponse.Content.CopyToAsync(response.OutputStream);
                    }
                }
                catch (Exception ex)
                {
                    response.StatusCode = 502; // Bad Gateway
                    response.ContentType = "text/plain";
                    await response.Output.WriteAsync($"Proxy Error: {ex.Message}");
                }
            }
        }

        private void CopyHeadersToProxyRequest(HttpRequest src, HttpRequestMessage dest)
        {
            foreach (string headerName in src.Headers)
            {
                string[] values = src.Headers.GetValues(headerName);
                if (values == null) continue;

                // Skip restricted headers that cannot be attached via DefaultRequestHeaders
                if (headerName.Equals("Host", StringComparison.OrdinalIgnoreCase) ||
                    headerName.Equals("Connection", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                // Try assigning to Content headers first if a body is present
                if (dest.Content != null && dest.Content.Headers.TryAddWithoutValidation(headerName, values))
                {
                    continue;
                }

                dest.Headers.TryAddWithoutValidation(headerName, values);
            }

            // Optional: inject standard X-Forwarded headers for backend context
            dest.Headers.TryAddWithoutValidation("X-Forwarded-For", src.UserHostAddress);
            dest.Headers.TryAddWithoutValidation("X-Forwarded-Host", src.Url.Host);
        }

        private void CopyHeadersToClientResponse(HttpResponseMessage src, HttpResponse dest)
        {
            // Copy standard response headers
            foreach (var header in src.Headers)
            {
                if (header.Key.Equals("Transfer-Encoding", StringComparison.OrdinalIgnoreCase)) continue;
                dest.Headers.Remove(header.Key); // Prevent duplicate response headers
                foreach (var val in header.Value)
                {
                    dest.Headers.Add(header.Key, val);
                }
            }

            // Copy content headers (e.g., Content-Type, Content-Length)
            foreach (var header in src.Content.Headers)
            {
                dest.Headers.Remove(header.Key);
                foreach (var val in header.Value)
                {
                    dest.Headers.Add(header.Key, val);
                }
            }
        }

        // Helper to convert async Tasks to Legacy APM pattern (Begin/End)
        private static IAsyncResult TaskToApm(Task task, AsyncCallback callback, object state)
        {
            var tcs = new TaskCompletionSource<object>(state);
            task.ContinueWith(t =>
            {
                if (t.IsFaulted) tcs.TrySetException(t.Exception.InnerExceptions);
                else if (t.IsCanceled) tcs.TrySetCanceled();
                else tcs.TrySetResult(null);

                callback?.Invoke(tcs.Task);
            }, TaskScheduler.Default);
            return tcs.Task;
        }
    }
}