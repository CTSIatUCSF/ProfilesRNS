SELECT TOP (1000) [UserAgent]
  FROM [profilesRNS].[User.Session].[Bot]

DROP TABLE [UCSF.].[OldBots];

select UserAgent, GETDATE() BackupDate INTO [UCSF.].[OldBots] FROM [User.Session].[Bot];

SELECT * FROM [UCSF.].[OldBots];

TRUNCATE TABLE [User.Session].[Bot];

-- comment out the redundant ones
INSERT [User.Session].[Bot] VALUES ('.*anirvan.*');
INSERT [User.Session].[Bot] VALUES ('.*bot.*');
INSERT [User.Session].[Bot] VALUES ('.*crawl.*');
INSERT [User.Session].[Bot] VALUES ('.*spider.*');
INSERT [User.Session].[Bot] VALUES ('.*acunetix.*');
INSERT [User.Session].[Bot] VALUES ('.*adscanner.*');
--INSERT [User.Session].[Bot] VALUES ('.*AhrefsBot.*');
INSERT [User.Session].[Bot] VALUES ('^Apache-HttpClient/.*');
--INSERT [User.Session].[Bot] VALUES ('.*Applebot.*');
INSERT [User.Session].[Bot] VALUES ('^axios/.*');
--INSERT [User.Session].[Bot] VALUES ('.*Baiduspider.*');
INSERT [User.Session].[Bot] VALUES ('.*BFAC.*');
INSERT [User.Session].[Bot] VALUES ('.*blackhat.*');
--INSERT [User.Session].[Bot] VALUES ('.*BLEXBot.*');
INSERT [User.Session].[Bot] VALUES ('.*Burp Suite.*');
--INSERT [User.Session].[Bot] VALUES ('.*Bytespider.*');
INSERT [User.Session].[Bot] VALUES ('.*CCBot.*');
INSERT [User.Session].[Bot] VALUES ('.*CheckMarkNetwork.*');
INSERT [User.Session].[Bot] VALUES ('^commix/.*');
INSERT [User.Session].[Bot] VALUES ('^curl/.*');
INSERT [User.Session].[Bot] VALUES ('.*Dataprovider.*');
--INSERT [User.Session].[Bot] VALUES ('.*Diffbot.*');
INSERT [User.Session].[Bot] VALUES ('.*dirbuster.*');
--INSERT [User.Session].[Bot] VALUES ('.*DotBot.*');
INSERT [User.Session].[Bot] VALUES ('^Drupal\b');  -- changed \\ to \ because no need to escape in DB
--INSERT [User.Session].[Bot] VALUES ('.*DuckDuckBot.*');
INSERT [User.Session].[Bot] VALUES ('.*EasyJSON.*');
--INSERT [User.Session].[Bot] VALUES ('.*FacebookBot.*');
INSERT [User.Session].[Bot] VALUES ('.*fimap.*');
INSERT [User.Session].[Bot] VALUES ('.*Google Favicon.*');
INSERT [User.Session].[Bot] VALUES ('.*Google-InspectionTool.*');
INSERT [User.Session].[Bot] VALUES ('.*Google-Read-Aloud.*');
--INSERT [User.Session].[Bot] VALUES ('.*Googlebot.*');
INSERT [User.Session].[Bot] VALUES ('.*GoogleOther.*');
INSERT [User.Session].[Bot] VALUES ('.*grabber.*');
INSERT [User.Session].[Bot] VALUES ('.*Hakai.*');
INSERT [User.Session].[Bot] VALUES ('.*HubSpot.*');
INSERT [User.Session].[Bot] VALUES ('.*jaeles.*');
INSERT [User.Session].[Bot] VALUES ('^Java/.*');
INSERT [User.Session].[Bot] VALUES ('.*JavaFX.*');
INSERT [User.Session].[Bot] VALUES ('.*Jigsaw.*');
INSERT [User.Session].[Bot] VALUES ('.*libwww-perl.*');
INSERT [User.Session].[Bot] VALUES ('.*linkcheck.*');
--INSERT [User.Session].[Bot] VALUES ('.*LinkedInBot.*');
INSERT [User.Session].[Bot] VALUES ('.*ltx71.*');
INSERT [User.Session].[Bot] VALUES ('.*masscan.*');
INSERT [User.Session].[Bot] VALUES ('.*Mediapartners-Google.*');
INSERT [User.Session].[Bot] VALUES ('.*MegaIndex.*');
--INSERT [User.Session].[Bot] VALUES ('.*MJ12bot.*');
--INSERT [User.Session].[Bot] VALUES ('.*MojeekBot.*');
--INSERT [User.Session].[Bot] VALUES ('.*MTRobot.*');
INSERT [User.Session].[Bot] VALUES ('.*Nikto.*');
INSERT [User.Session].[Bot] VALUES ('.*nmap.*');
INSERT [User.Session].[Bot] VALUES ('.*Nutch.*');
INSERT [User.Session].[Bot] VALUES ('.*OpenVAS.*');
--INSERT [User.Session].[Bot] VALUES ('.*PetalBot.*');
--INSERT [User.Session].[Bot] VALUES ('.*Pinterestbot.*');
INSERT [User.Session].[Bot] VALUES ('^Postman.*');
INSERT [User.Session].[Bot] VALUES ('^Python.*');
INSERT [User.Session].[Bot] VALUES ('.*Riddler.*');
INSERT [User.Session].[Bot] VALUES ('^Ruby.*');
--INSERT [User.Session].[Bot] VALUES ('.*RyteBot.*');
INSERT [User.Session].[Bot] VALUES ('.*scoutjet.*');
INSERT [User.Session].[Bot] VALUES ('^Scrapy.*');
INSERT [User.Session].[Bot] VALUES ('.*Search API');
--INSERT [User.Session].[Bot] VALUES ('.*semanticbot.*');
--INSERT [User.Session].[Bot] VALUES ('.*SemrushBot.*');
--INSERT [User.Session].[Bot] VALUES ('.*SeznamBot.*');
INSERT [User.Session].[Bot] VALUES ('.*Slurp.*');
--INSERT [User.Session].[Bot] VALUES ('.*SMTBot.*');
--INSERT [User.Session].[Bot] VALUES ('.*Sogou Spider.*');
--INSERT [User.Session].[Bot] VALUES ('.*Sosospider.*');
INSERT [User.Session].[Bot] VALUES ('.*sqlmap.*');
INSERT [User.Session].[Bot] VALUES ('.*Telesphoreo.*');
--INSERT [User.Session].[Bot] VALUES ('.*Twitterbot.*');
--INSERT [User.Session].[Bot] VALUES ('.*UptimeRobot.*');
--INSERT [User.Session].[Bot] VALUES ('.*VelenPublicWebCrawler.*');
INSERT [User.Session].[Bot] VALUES ('.*w3af.*');
INSERT [User.Session].[Bot] VALUES ('^WordPress.*');
INSERT [User.Session].[Bot] VALUES ('.*WPScan.*');
INSERT [User.Session].[Bot] VALUES ('.*www-perl.*');
INSERT [User.Session].[Bot] VALUES ('.*Xenu Link Sleuth.*');
INSERT [User.Session].[Bot] VALUES ('.*Y!J-BRW.*');
--INSERT [User.Session].[Bot] VALUES ('.*YandexBot.*');
INSERT [User.Session].[Bot] VALUES ('.*YandexImages.*');
--INSERT [User.Session].[Bot] VALUES ('.*YetiBot.*');
--INSERT [User.Session].[Bot] VALUES ('.*ZoominfoBot.*');
INSERT [User.Session].[Bot] VALUES ('.*CensysInspect.*');
INSERT [User.Session].[Bot] VALUES ('^Owler.*');
INSERT [User.Session].[Bot] VALUES ('^Uptime-Kuma.*');
INSERT [User.Session].[Bot] VALUES ('^search\.marginalia\.nu.*');
INSERT [User.Session].[Bot] VALUES ('^Jetty/.*');

