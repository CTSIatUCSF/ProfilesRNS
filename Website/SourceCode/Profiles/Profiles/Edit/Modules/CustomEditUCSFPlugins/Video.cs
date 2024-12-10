using Newtonsoft.Json;
using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Web;

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
            completeVideoMetadata(null);
        }
        public void completeVideoMetadata(string youTubeId)
        {
            // get metadata if needed
            if (!String.IsNullOrEmpty(thumbnail_url) && !String.IsNullOrEmpty(html) && !String.IsNullOrEmpty(title))
            {
                return;
            }
            else if (String.IsNullOrEmpty(youTubeId) || String.IsNullOrEmpty(title))
            {
                VideoMetadata v = Video.getVideoMetadata(url, 75, 125);
                url = v.url; // get cleaned URL
                // if we don't have the oembed data, throw a more meaningful exception  
                if (v.oembed == null)
                {
                    throw new Exception("Embedded video data missing from video service");
                }
                title = String.IsNullOrEmpty(title) ? v.oembed.title : title;
                thumbnail_url = v.oembed.thumbnail_url;
                html = v.oembed.html;
                updated = DateTime.Now.ToString("yyyy-MM-dd");
            }
            else
            {
                url = "http://www.youtube.com/watch?v=" + youTubeId;
                thumbnail_url = "https://img.youtube.com/vi/" + youTubeId + "/hqdefault.jpg";
                html = "<iframe width=\"125px\" height=\"75px\"  src=\"https://www.youtube.com/embed/" + youTubeId + "?autoplay=0&rel=0\"></iframe>";
            }
        }

        public class VideoMetadata
        {
            public string url { get; set; }
            public Oembed oembed { get; set; }
        }

        public class Oembed
        {
            public string title { get; set; }
            public string thumbnail_url { get; set; }
            public string html { get; set; }
        }

        private static VideoMetadata getVideoMetadata(String url, int max_height, int max_width)
        {
            //String oEmbedURLBase = "https://noembed.com/embed";
            String oEmbedURLBase = "https://api.embed.rocks/api";

            String oembedURL = oEmbedURLBase + "?url=" + HttpUtility.UrlEncode(url) + "&include=oembed&skip=html&maxwidth=" + max_width;

            HttpWebRequest myReq = (HttpWebRequest)WebRequest.Create(oembedURL);
            myReq.Accept = "application/json"; // "application/ld+json";
            myReq.Headers.Add("x-api-key", ConfigurationManager.AppSettings["EmbedRocksAPIKey"]);

            String jsonProfiles = "";
            using (StreamReader sr = new StreamReader(myReq.GetResponse().GetResponseStream()))
            {
                jsonProfiles = sr.ReadToEnd();
            }

            return JsonConvert.DeserializeObject<VideoMetadata>(jsonProfiles);
        }

    }
}