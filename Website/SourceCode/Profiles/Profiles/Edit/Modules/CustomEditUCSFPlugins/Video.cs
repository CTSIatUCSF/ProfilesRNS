using Newtonsoft.Json;
using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using HtmlAgilityPack;
using System.Security.Policy;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public class Video
    {
        public string url { get; set; }
        public string title { get; set; }
        public string thumbnail_url { get; set; }
        public string html { get; set; }
        public string updated { get; set; } //DateTime.Now.ToString("yyyy-MM-dd");

        public void completeVideoMetadata()
        {
            if (string.IsNullOrEmpty(url))
            {
                throw new ArgumentException("URL cannot be null or empty.");
            }
            // Maybe don't process if the html and thumbnail_url is done. 
            // Check that update does, however, reprocess everything.

            Uri videoUri;
            if (!Uri.TryCreate(url, UriKind.Absolute, out videoUri))
            {
                throw new ArgumentException("Invalid URL format.");
            }

            string domain = videoUri.Host.ToLower();

            if (domain.Contains("youtube.com") || domain.Contains("youtu.be"))
            {
                string videoId = ExtractYouTubeId(url);
                if (!string.IsNullOrEmpty(videoId))
                {
                    html = $"<iframe width='640' height='360' " +
                           $"src='https://www.youtube.com/embed/{videoId}' " +
                           $"alt='{title}' " +
                           $"frameborder='0' allowfullscreen></iframe>";
                    thumbnail_url = $"https://img.youtube.com/vi/{videoId}/hqdefault.jpg";
                }
            }
            else if (domain.Contains("vimeo.com"))
            {
                string videoId = ExtractVimeoId(url);
                if (!string.IsNullOrEmpty(videoId))
                {
                    html = $"<iframe width='640' height='360' " +
                           $"src='https://player.vimeo.com/video/{videoId}' " +
                           $"alt='{title}' " +
                           $"frameborder='0' allowfullscreen></iframe>";
                    thumbnail_url = ScrapeOgImage(url);
                }
            }
            else if (domain.Contains("ted.com"))
            {
                string talkName = ExtractTedTalkName(url);
                if (!string.IsNullOrEmpty(talkName))
                {
                    html = $"<iframe width='640' height='360' " +
                           $"src='https://embed.ted.com/talks/{talkName}' " +
                           $"alt='{title}' " +
                           $"frameborder='0' allowfullscreen></iframe>";
                    thumbnail_url = ScrapeOgImage(url) ?? GetGenericThumbnail();
                }
            }
            else if (domain.Contains("instagram.com") && url.Contains("/reel/"))
            {
                string reelId = ExtractInstagramReelId(url);
                if (!string.IsNullOrEmpty(reelId))
                {
                    html = $"<iframe width='640' height='360' " +
                           $"src='https://www.instagram.com/reel/{reelId}/embed' " +
                           $"alt='{title}' " +
                           $"frameborder='0' allowfullscreen></iframe>";
                    thumbnail_url = ScrapeOgImage(url) ?? GetGenericThumbnail();
                }
            }
            else if (domain.Contains("tiktok.com"))
            {
                string videoId = ExtractTikTokVideoId(url);
                if (!string.IsNullOrEmpty(videoId))
                {
                    html = $"<iframe width='640' height='360' " +
                           $"src='https://www.tiktok.com/embed/v2/{videoId}' " +
                           $"alt='{title}' " +
                           $"frameborder='0' allowfullscreen></iframe>";
                    thumbnail_url = ScrapeOgImage(url) ?? GetGenericThumbnail();
                }
            }
            else if (domain.Contains("twitch.tv") || domain.Contains("clips.twitch.tv"))
            {
                string clipId = ExtractTwitchClipId(url);
                if (!string.IsNullOrEmpty(clipId))
                {
                    html = $"<iframe width='640' height='360' " +
                           $"src='https://clips.twitch.tv/embed?clip={clipId}&parent=example.com' " +
                           $"alt='{title}' " +
                           $"frameborder='0' allowfullscreen></iframe>";
                    thumbnail_url = $"https://clips-media-assets2.twitch.tv/{clipId}-preview.jpg";
                }
            }
            else if (url.EndsWith(".mp4", StringComparison.OrdinalIgnoreCase) && videoUri.AbsolutePath.Split('/').Length > 1)
            {
                html = $"<video width='640' height='360' controls>" +
                       $"<source src='{url}' type='video/mp4'>" +
                       "Your browser does not support the video tag.</video>";
                thumbnail_url = GetGenericThumbnail();
            }
            else
            {
                throw new NotSupportedException("Unsupported video platform.");
            }

            updated = DateTime.Now.ToString("yyyy-MM-dd");
        }

        private static string ExtractYouTubeId(string url)
        {
            var regex = new Regex(@"(?:youtu\.be/|youtube\.com/(?:watch\?v=|embed/|v/))([\w\-]+)");
            var match = regex.Match(url);
            return match.Success ? match.Groups[1].Value : null;
        }

        private static string ExtractVimeoId(string url)
        {
            var regex = new Regex(@"vimeo\.com/(\d+)");
            var match = regex.Match(url);
            return match.Success ? match.Groups[1].Value : null;
        }

        private static string ExtractTedTalkName(string url)
        {
            var regex = new Regex(@"ted\.com/talks/([\w\-]+)");
            var match = regex.Match(url);
            return match.Success ? match.Groups[1].Value : null;
        }

        private static string ExtractInstagramReelId(string url)
        {
            var regex = new Regex(@"/reel/([\w\-]+)/?");
            var match = regex.Match(url);
            return match.Success ? match.Groups[1].Value : null;
        }

        private static string ExtractTikTokVideoId(string url)
        {
            var regex = new Regex(@"video/(\d+)");
            var match = regex.Match(url);
            return match.Success ? match.Groups[1].Value : null;
        }

        private static string ExtractTwitchClipId(string url)
        {
            var regex = new Regex(@"(?:/clip/|clips\.twitch\.tv/)([\w\-]+)");
            var match = regex.Match(url);
            return match.Success ? match.Groups[1].Value : null;
        }

        private string ScrapeOgImage(string videoUrl)
        {
            HttpWebRequest myReq = (HttpWebRequest)WebRequest.Create(videoUrl);
            String pageContent = "";
            using (StreamReader sr = new StreamReader(myReq.GetResponse().GetResponseStream()))
            {
                pageContent = sr.ReadToEnd();
            }

            HtmlDocument htmlDocument = new HtmlDocument();
            htmlDocument.LoadHtml(pageContent);

            // TODO. Note that this may return null, need to deal with appropriately
            HtmlNode metaTag = htmlDocument.DocumentNode.SelectSingleNode("//meta[@property='og:image']");
            return metaTag.GetAttributeValue("content", null);
        }

        private string GetGenericThumbnail()
        {
            return "https://example.com/default-thumbnail.jpg";
        }
    }
}