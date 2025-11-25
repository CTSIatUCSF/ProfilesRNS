<%@ Page Language="C#" ContentType="text/plain" EnableTheming="false" Theme="" %>
<%Response.Write("User-Agent: *" + Environment.NewLine);%>
<%Response.Write("Disallow: /shindigorng/" + Environment.NewLine);%>
<%Response.Write("Disallow: /sparql/" + Environment.NewLine);%>
<%Response.Write("Disallow: /profile/" + Environment.NewLine);%>
<%Response.Write("Disallow: /Profile/" + Environment.NewLine);%>
<%Response.Write("Disallow: /display/" + Environment.NewLine);%>
<%Response.Write("Disallow: /login/" + Environment.NewLine);%>
<%Response.Write("Disallow: /Activity/" + Environment.NewLine);%>
<%Response.Write("Disallow: /error/" + Environment.NewLine);%>
<%Response.Write("Disallow: /Error/" + Environment.NewLine);%>
<%Response.Write("Disallow: /ORNG/" + Environment.NewLine);%>
<%Response.Write("Disallow: /search/default.aspx" + Environment.NewLine);%>
<%Response.Write("Allow: /profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx" + Environment.NewLine);%>
<%Response.Write(Environment.NewLine);%>
<%Response.Write("Sitemap: " + Request.Url.Scheme + "://" + Request.Url.Host + "/sitemap.xml" + Environment.NewLine);%>
<%Response.Write("Crawl-Delay: 10" + Environment.NewLine);%>