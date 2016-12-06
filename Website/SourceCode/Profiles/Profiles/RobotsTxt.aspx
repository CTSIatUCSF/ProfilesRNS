<%@ Page Language="C#" ContentType="text/plain" EnableTheming="false" Theme="" %>
<%Response.Write("User-Agent: *" + Environment.NewLine);%>
<%Response.Write("Disallow: /shindigorng/" + Environment.NewLine);%>
<%Response.Write("Disallow: /sparql/" + Environment.NewLine);%>
<%Response.Write("Disallow: /profile/" + Environment.NewLine);%>
<%Response.Write("Disallow: /display/" + Environment.NewLine);%>
<%Response.Write("Sitemap: " + Profiles.Framework.Utilities.Root.Domain + "/sitemap.xml" + Environment.NewLine);%>
<%Response.Write("Crawl-Delay: 10" + Environment.NewLine);%>