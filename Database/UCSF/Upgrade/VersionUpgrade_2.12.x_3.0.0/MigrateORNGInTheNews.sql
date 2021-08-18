/*******************************
*
* Convert In The News Data. 
* If you did not have the open social websites app installed you can skip this script
*
* This Script is split into 3 sections
* 1. Convert website data to the new format
* 2. Convert security settings to the new nodes
* 3. Generate the RDF
*
* Run each step one at a time, and confirm that there were no errors before going on to the next step.
* After step 1, we recommend looking in the websites tables and confirming the websites are correct for a few people
* before progressing to step 2.
* 
* Ensure step 2 completes without errors before progressing to step 3. Any errors during steps 1 and 2 will be 
* pushed into the RDF data during step 3, and will be much harder to fix after running step 3
*
*******************************/

declare @appID int
select @appID = AppID from [ORNG.].[Apps] where Url like '%/MediaLinks.xml' 

-- see how big chunked data is
SELECT * FROM  [ORNG.].[AppData] WHERE AppID = @AppID and Keyname = 'links.count';

create table #medialinksJson (
	nodeid bigint,
	[Value] varchar(max)
)

-- do simple stuff first
INSERT  #medialinksJson SELECT NodeID, [Value] FROM [ORNG.].[AppData] WHERE AppID = @AppID and Keyname = 'links' AND Value != '---DATA CHUNKED BY ORNG SYSTEM---';

-- now do chunks, add more UPDATE lines if needed based on links.count and increment number in Keyname
INSERT  #medialinksJson SELECT NodeID, [Value] FROM [ORNG.].[AppData] WHERE AppID = @AppID and Keyname = 'links.0';
UPDATE ml SET ml.[Value] = ml.[Value] + ad.[Value] FROM #medialinksJson ml 
	JOIN [ORNG.].[AppData] ad ON ml.nodeid = ad.NodeID AND ad.AppID = @AppID and ad.Keyname = 'links.1';

SELECT *, ISJSON([Value]) FROM #medialinksJson WHERE NodeID in 
(Select NodeID FROM [ORNG.].[AppData] WHERE AppID = @AppID and Keyname = 'links.count')
--DROP TABLE #medialinksJson

--[{"link_name":"The Sugar Industry Shaped Government Advice On Cavities, Report Finds","link_url":"http://time.com/3738706/the-sugar-industry-shaped-government-advice-on-cavities-report-finds/","link_date":"03/10/2015"},{"link_name":"Sugar - the diabolical toxic poison (German publication)","link_url":"http://www.welt.de/gesundheit/article135567307/Zucker-der-teuflisch-giftige-Dickmacher.html","link_date":"01/19/2015"},{"link_name":"Scientists Say Sugar Could Be Source of Disease","link_url":"http://www.cbn.com/tv/embedplayernews.aspx?bcid=3971691058001","link_date":"01/05/2015"},{"link_name":"Scientific team sounds the alarm on sugar as a source of disease","link_url":"http://www.philly.com/philly/health/fitness/287346991.html","link_date":"01/05/2015"},{"link_name":"Sugar Is Making Us Really Sick","link_url":"http://www.newser.com/story/200838/sugar-is-making-us-really-sick.html","link_date":"01/05/2015"},{"link_name":"UCSF’s SugarScience Educates the Public on the Truth behind Added Sugar","link_url":"http://synapse.ucsf.edu/articles/2014/12/21/do-you-have-sugar-belly-ucsfs-sugarscience-educates-public-truth-behind-added","link_date":"12/21/2014"},{"link_name":"UCSF develops sugar science site to improve nation's health","link_url":"http://www.capecodonline.com/article/20141120/News/141129980","link_date":"12/10/2014"},{"link_name":"Scientific team sounds warning about sugar as a source of disease","link_url":"http://www.chicagotribune.com/lifestyles/health/sc-health-1210-sugar-metabolic-syndrome-20141205-story.html","link_date":"12/05/2014"},{"link_name":"Studies show consuming excess sugar can lead to wrinkles, liver damage, even loss of limbs","link_url":"http://www.winnipegfreepress.com/opinion/columnists/sweet--poison-283669921.html","link_date":"11/24/2014"},{"link_name":"Studies show consuming excess sugar can lead to wrinkles, liver damage, even loss of limbs","link_url":"http://www.winnipegfreepress.com/opinion/columnists/sweet--poison-283669921.html","link_date":"11/24/2014"},{"link_name":"Researchers Campaign Against Americans’ Sweet Tooth With Public Health Initiative","link_url":"http://www.washingtonpost.com/postlive/researchers-campaign-against-americans-sweet-tooth-with-public-health-initiative/2014/11/20/77e3efd4-6f94-11e4-8808-afaa1e3a33ef_story.html","link_date":"11/21/2014"},{"link_name":"If You've Already Cut Out Sugary Drinks, This Should Be Your Next Goal","link_url":"http://www.huffingtonpost.com/2014/11/17/sugarscience-ucsf_n_6155940.html","link_date":"11/19/2014"},{"link_name":"Sugar Isn't Just Making You Fat-It's Making You Sick","link_url":"http://www.takepart.com/article/2014/11/14/sugar-isnt-just-making-you-fat-its-making-you-sick-0","link_date":"11/14/2014"},{"link_name":"The Hidden Costs of Sugar","link_url":"http://www.ucsf.edu/news/2014/11/120756/hidden-costs-sugar","link_date":"11/13/2014"},{"link_name":"UCSF Initiative Links ‘Sugar Science’ to Your Health","link_url":"http://well.blogs.nytimes.com/2014/11/12/website-explores-sugars-effects-on-health/","link_date":"11/12/2014"},{"link_name":"New Site Sheds Light on Sugar","link_url":"http://dailyrxnews.com/new-site-sheds-light-on-sugar/","link_date":"11/12/2014"},{"link_name":"UCSF develops Site to Make Sense Out of Sugar Science","link_url":"http://www.sfgate.com/health/article/UCSF-develops-site-to-make-sense-out-of-sugar-5884346.php","link_date":"11/12/2014"},{"link_name":"A New Project Reveals The Truth About Sugar","link_url":"http://www.harpersbazaar.com/beauty/health-wellness-articles/health-effects-of-sugar","link_date":"11/11/2014"},{"link_name":"Need help kicking your sugar habit? This might help.","link_url":"http://www.washingtonpost.com/news/to-your-health/wp/2014/11/11/need-help-kicking-your-sugar-habit-this-might-help/","link_date":"11/11/2014"},{"link_name":"New UCSF Website Explores Health Effects Of Sugar Overconsumption","link_url":"http://abc7news.com/health/new-website-explores-effects-of-eating-too-much-sugar-/389379/","link_date":"11/10/2014"},{"link_name":"New Public Health Initiative to Distill Dangers of Too Much Sugar","link_url":"https://soundcloud.com/kqed/new-public-health-initiative-to-distill-dangers-of-too-much-sugar","link_date":"11/10/2014"},{"link_name":"UCSF sugar science initiative launched","link_url":"http://health.universityofcalifornia.edu/2014/11/10/ucsf-sugar-science-initiative-launched/","link_date":"11/10/2014"},{"link_name":"How Much Sugar Is Too Much? A New Tool Sheds Some Light","link_url":"http://www.npr.org/blogs/thesalt/2014/11/10/363058314/how-much-sugar-is-too-much-a-new-tool-sheds-some-light","link_date":"11/10/2014"},{"link_name":"UCSF Initiative Links ‘Sugar Science’ to Your Health","link_url":"http://blogs.kqed.org/stateofhealth/2014/11/10/ucsf-initiative-links-sugar-science-to-your-health/","link_date":"11/10/2014"},{"link_name":"UCSF's Wellness Expo Focuses on Healthy Eating, Fostering Happiness","link_url":"http://www.ucsf.edu/news/2012/02/11475/ucsfs-wellness-expo-focuses-healthy-eating-fostering-happiness","link_date":"02/07/2012"},{"link_name":"Societal Control of Sugar Essential to Ease Public Health Burden","link_url":"http://www.ucsf.edu/news/2012/02/11437/societal-control-sugar-essential-ease-public-health-burden","link_date":"02/01/2012"},{"link_name":"2011: The Year in Pictures","link_url":"http://www.ucsf.edu/news/2011/12/11153/2011-year-pictures","link_date":"12/20/2011"},{"link_name":"San Francisco Health Improvement Partnerships Tackle Public Health Problems","link_url":"http://www.ucsf.edu/news/2011/12/11030/san-francisco-health-improvement-partnerships-tackle-public-health-problems","link_date":"12/01/2011"},{"link_name":"UCSF Students Pack Classroom to Learn About Health Care Reform","link_url":"http://www.ucsf.edu/news/2011/10/10730/ucsf-students-pack-classroom-learn-about-health-care-reform","link_date":"10/03/2011"},{"link_name":"\"The Toxic Truth About Sugar\"","link_url":"http://www.youtube.com/watch?v=ffoOeW5wZ9s&feature=youtu.be&utm_source=Feburary+2012+Staff&utm_campaign=Pulse+Feb12+Staff&utm_medium=email","link_date":""}]

-- Fix bad JSON
SELECT * FROM #medialinksJson WHERE ISJSON([Value]) = 0
--DELETE FROM #medialinksJson WHERE ISJSON([Value]) = 0 
--[{"link_name":"Sam Hawgood Takes the Helm at UCSF","link_url":"http://www.ucsf.edu/news/2014/03/113091/sam-hawgood-takes-helm-uc-san-francisco","link_date":"04/01/2014"},{"link_name":"Sam Hawgood Named Interim UCSF Chancellor ","link_url":"http://www.ucsf.edu/news/2014/01/111401/sam-hawgood-named-interim-chancellor","link_date":"01/23/2014"},{"link_name":"Preparing for Faculty of the Future","link_url":"http://www.ucsf.edu/news/2013/02/13483/preparing-faculty-future","link_date":"02/05/2013"},{"link_name":"AAMC Board Chair Mark Laret Calls On Academic Medical Centers to 'Think Differently'","link_url":"http://www.ucsf.edu/news/2012/11/13094/aamc-board-chair-mark-laret-calls-academic-medical-centers-think-differently","link_date":"11/08/2012"},{"link_name":"Three UCSF Faculty Members Named to Institute of Medicine","link_url":"http://www.ucsf.edu/news/2012/10/12955/three-ucsf-faculty-members-named-institute-medicine","link_date":"10/15/2012"},{"link_name":"Neural Stem Cell Study Arose from Culture of Collaboration That Drives Clinical Innovation","link_url":"http://www.ucsf.edu/news/2012/10/12942/neural-stem-cell-study-arose-culture-collaboration-drives-clinical-innovation","link_date":"10/10/2012"},{"link_name":"UCSF and Gladstone Celebrate Shinya Yamanaka's Nobel Prize in Medicine","link_url":"http://www.ucsf.edu/news/2012/10/12926/ucsf-and-gladstone-celebrate-shinya-yamanakas-nobel-prize-medicine","link_date":"10/08/2012"},{"link_name":"New Anatomy Learning Center Prepares Next Generation of Clinicians","link_url":"http://www.ucsf.edu/news/2012/09/12775/new-anatomy-learning-center-prepares-next-generation-clinicians","link_date":"09/26/2012"},{"link_name":"White Coat Ceremony Marks Start of Medical School at UCSF","link_url":"http://www.ucsf.edu/news/2012/09/12794/white-coat-ceremony-marks-start-medical-school-ucsf","link_date":"09/26/2012"},{"link_name":"New Technology to Improve Patient Care Highlighted at Dreamforce 2012","link_url":"http://www.ucsf.edu/news/2012/09/12780/new-technology-improve-patient-care-highlighted-dreamforce-2012","link_date":"09/24/2012"},{"link_name":"UCSF Students, Residents Take Center Stage at Research Festival","link_url":"http://www.ucsf.edu/news/2012/05/11987/ucsf-students-residents-take-center-stage-research-festival","link_date":"05/08/2012"},{"link_name":"Paul Volberding Takes Leading Roles with UCSF's ARI, Global Health Sciences","link_url":"http://www.ucsf.edu/news/2012/02/11541/paul-volberding-takes-leading-roles-ucsfs-ari-global-health-sciences","link_date":"02/17/2012"},{"link_name":"Who's Who in the \"Future of UCSF\" Working Group","link_url":"http://www.ucsf.edu/news/2012/02/11484/whos-who-future-ucsf-working-group","link_date":"02/09/2012"},{"link_name":"Media Advisory: UCSF to Host Symposium on Tobacco Research","link_url":"http://www.ucsf.edu/news/2012/02/11442/media-advisory-ucsf-host-symposium-tobacco-research","link_date":"02/02/2012"},{"link_name":"UCSF School of Medicine Leaders Explore Bioinformatics in Research, Patient Care and Education","link_url":"http://www.ucsf.edu/news/2012/01/11401/ucsf-school-medicine-leaders-explore-bioinformatics","link_date":"01/30/2012"},{"link_name":"Colleagues React to Koda-Kimble's Legacy at UCSF","link_url":"http://www.ucsf.edu/news/2012/01/11338/colleagues-react-koda-kimbles-legacy-ucsf","link_date":"01/23/2012"},{"link_name":"UCSF Biochemist Wins Prestigious Prize","link_url":"http://www.ucsf.edu/news/2011/12/11206/ucsf-biochemist-wins-prestigious-prize","link_date":"12/22/2011"},{"link_name":"2011: The Year in Pictures","link_url":"http://www.ucsf.edu/news/2011/12/11153/2011-year-pictures","link_date":"12/20/2011"},{"link_name":"UCSF to Receive Tobacco Papers, Funding to Improve Public Access to the Documents","link_url":"http://www.ucsf.edu/news/2011/12/11138/ucsf-receive-tobacco-papers-funding-improve-public-access-documents","link_date":"12/13/2011"},{"link_name":"UCSF Medical Center at Mission Bay Celebrates \"Topping Out\" Constru

 -- find max amount but altering the number here and seeing biggest value to return something. Check appid!!
SELECT * FROM #medialinksJson WHERE JSON_VALUE([Value], '$[30].link_name') IS NOT NULL;

create table #medialinks (
	nodeid bigint,
	link_name varchar(max),
	link_url varchar(max),
	link_date varchar(100),
	sort_order int,
	PersonID int,
	GroupID int 
)

-- PRINT OUT stuff, set limit based on value where [].link_name is finally null
DECLARE @ndx int = 0
WHILE @ndx < 30
BEGIN
	PRINT 'INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], ''$[' + cast(@ndx as varchar) + 
			'].link_name''), JSON_VALUE(d.[Value], ''$[' + cast(@ndx as varchar) + '].link_url''), JSON_VALUE(d.[Value], ''$[' + cast(@ndx as varchar) + 
			'].link_date''),  ' + cast(@ndx as varchar) + ', p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], ''$[' + cast(@ndx as varchar) + '].link_name'') IS NOT NULL;';
	SET @ndx = @ndx + 1
END
--exectue the results from above WHILE loop to Migrate data into #medialinks
-- CUT AND PASTE START
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[0].link_name'), JSON_VALUE(d.[Value], '$[0].link_url'), JSON_VALUE(d.[Value], '$[0].link_date'),  0, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[0].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[1].link_name'), JSON_VALUE(d.[Value], '$[1].link_url'), JSON_VALUE(d.[Value], '$[1].link_date'),  1, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[1].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[2].link_name'), JSON_VALUE(d.[Value], '$[2].link_url'), JSON_VALUE(d.[Value], '$[2].link_date'),  2, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[2].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[3].link_name'), JSON_VALUE(d.[Value], '$[3].link_url'), JSON_VALUE(d.[Value], '$[3].link_date'),  3, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[3].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[4].link_name'), JSON_VALUE(d.[Value], '$[4].link_url'), JSON_VALUE(d.[Value], '$[4].link_date'),  4, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[4].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[5].link_name'), JSON_VALUE(d.[Value], '$[5].link_url'), JSON_VALUE(d.[Value], '$[5].link_date'),  5, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[5].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[6].link_name'), JSON_VALUE(d.[Value], '$[6].link_url'), JSON_VALUE(d.[Value], '$[6].link_date'),  6, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[6].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[7].link_name'), JSON_VALUE(d.[Value], '$[7].link_url'), JSON_VALUE(d.[Value], '$[7].link_date'),  7, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[7].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[8].link_name'), JSON_VALUE(d.[Value], '$[8].link_url'), JSON_VALUE(d.[Value], '$[8].link_date'),  8, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[8].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[9].link_name'), JSON_VALUE(d.[Value], '$[9].link_url'), JSON_VALUE(d.[Value], '$[9].link_date'),  9, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[9].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[10].link_name'), JSON_VALUE(d.[Value], '$[10].link_url'), JSON_VALUE(d.[Value], '$[10].link_date'),  10, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[10].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[11].link_name'), JSON_VALUE(d.[Value], '$[11].link_url'), JSON_VALUE(d.[Value], '$[11].link_date'),  11, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[11].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[12].link_name'), JSON_VALUE(d.[Value], '$[12].link_url'), JSON_VALUE(d.[Value], '$[12].link_date'),  12, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[12].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[13].link_name'), JSON_VALUE(d.[Value], '$[13].link_url'), JSON_VALUE(d.[Value], '$[13].link_date'),  13, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[13].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[14].link_name'), JSON_VALUE(d.[Value], '$[14].link_url'), JSON_VALUE(d.[Value], '$[14].link_date'),  14, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[14].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[15].link_name'), JSON_VALUE(d.[Value], '$[15].link_url'), JSON_VALUE(d.[Value], '$[15].link_date'),  15, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[15].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[16].link_name'), JSON_VALUE(d.[Value], '$[16].link_url'), JSON_VALUE(d.[Value], '$[16].link_date'),  16, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[16].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[17].link_name'), JSON_VALUE(d.[Value], '$[17].link_url'), JSON_VALUE(d.[Value], '$[17].link_date'),  17, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[17].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[18].link_name'), JSON_VALUE(d.[Value], '$[18].link_url'), JSON_VALUE(d.[Value], '$[18].link_date'),  18, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[18].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[19].link_name'), JSON_VALUE(d.[Value], '$[19].link_url'), JSON_VALUE(d.[Value], '$[19].link_date'),  19, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[19].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[20].link_name'), JSON_VALUE(d.[Value], '$[20].link_url'), JSON_VALUE(d.[Value], '$[20].link_date'),  20, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[20].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[21].link_name'), JSON_VALUE(d.[Value], '$[21].link_url'), JSON_VALUE(d.[Value], '$[21].link_date'),  21, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[21].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[22].link_name'), JSON_VALUE(d.[Value], '$[22].link_url'), JSON_VALUE(d.[Value], '$[22].link_date'),  22, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[22].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[23].link_name'), JSON_VALUE(d.[Value], '$[23].link_url'), JSON_VALUE(d.[Value], '$[23].link_date'),  23, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[23].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[24].link_name'), JSON_VALUE(d.[Value], '$[24].link_url'), JSON_VALUE(d.[Value], '$[24].link_date'),  24, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[24].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[25].link_name'), JSON_VALUE(d.[Value], '$[25].link_url'), JSON_VALUE(d.[Value], '$[25].link_date'),  25, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[25].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[26].link_name'), JSON_VALUE(d.[Value], '$[26].link_url'), JSON_VALUE(d.[Value], '$[26].link_date'),  26, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[26].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[27].link_name'), JSON_VALUE(d.[Value], '$[27].link_url'), JSON_VALUE(d.[Value], '$[27].link_date'),  27, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[27].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[28].link_name'), JSON_VALUE(d.[Value], '$[28].link_url'), JSON_VALUE(d.[Value], '$[28].link_date'),  28, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[28].link_name') IS NOT NULL;
INSERT INTO #medialinks SELECT d.NodeID, JSON_VALUE(d.[Value], '$[29].link_name'), JSON_VALUE(d.[Value], '$[29].link_url'), JSON_VALUE(d.[Value], '$[29].link_date'),  29, p.PersonID, null FROM #medialinksJson d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID AND JSON_VALUE(d.[Value], '$[29].link_name') IS NOT NULL;

-- CUT AND PASTE END
SELECT * FROM #medialinks;
--DROP TABLE #medialinks


insert into [Profile.Data].[Person.MediaLinks] (URLID, PersonID, URL, WebPageTitle, PublicationDate,  SortOrder)
select newID(), PersonID, link_url, link_name, link_date, sort_order from #medialinks where personID is not null

insert into [Profile.Data].[Group.MediaLinks] (URLID, GroupID, URL, WebPageTitle, PublicationDate,  SortOrder)
select newID(), GroupID,  link_url, link_name, link_date, sort_order from #medialinks where GroupID is not null

--select * from [Profile.Data].[Person.MediaLinks]
--select * from [Profile.Data].[Group.MediaLinks] 
--select * from #medialinks

drop table #medialinks

/***********************
* End of Section 1
* MediaLinks data has been converted to the new format, 
* This data can be inspected using the following queries:
*    select * from [Profile.Data].[Person.Websites]
*    select * from [Profile.Data].[Group.Websites]
* 
* If this section ran without errors, and the data looks good
* you can progress to section 2.
***********************/

declare @wNodeID bigint, @orngwNodeID bigint
select @wNodeID = NodeID from [RDF.].[Node] where value in ('http://profiles.catalyst.harvard.edu/ontology/prns#mediaLinks') 
select @orngwNodeID = NodeID from [RDF.].[Node] where value in ('http://orng.info/ontology/orng#hasMediaLinks')

insert into [RDF.Security].NodeProperty (NodeID, Property, ViewSecurityGroup)
select nodeID, @wNodeID, ViewSecurityGroup from [RDF.Security].NodeProperty where Property = @orngwNodeID

update [RDF.].Triple set ViewSecurityGroup = -50 where Predicate = @orngwNodeID

update [Ontology.].ClassProperty set
	ViewSecurityGroup = -50,
	EditSecurityGroup = -50,
	EditPermissionsSecurityGroup = -50,
	EditExistingSecurityGroup = -50,
	EditAddNewSecurityGroup = -50,
	EditAddExistingSecurityGroup = -50,
	EditDeleteSecurityGroup = -50 
	where property = 'http://orng.info/ontology/orng#hasMediaLinks'

/***********************
* End of Section 2
* Security groups should be correct at this point
*
* If this section ran correcty, you can run section 3
***********************/

declare @d1 int, @d2 int, @d3 int, @d4 int, @d5 int, @d6 int, @d7 int
select @d1 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property is null
select @d2 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
select @d3 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://www.w3.org/2000/01/rdf-schema#label'
select @d4 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#publicationDate'
select @d5 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://vivoweb.org/ontology/core#linkAnchorText'
select @d6 = DataMapID from [Ontology.].DataMap where class = 'http://xmlns.com/foaf/0.1/Group' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#mediaLinks'
select @d7 = DataMapID from [Ontology.].DataMap where class = 'http://xmlns.com/foaf/0.1/Person' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#mediaLinks'

EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d1, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d2, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d3, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d4, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d5, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d6, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d7, @ShowCounts = 1


/***********************
* End of Section 3
* Websites should be fully converted to the new websites module
***********************/
-- Now remove the ORNG app from people
DECLARE @vNodeID BIGINT
DECLARE @vAppID int
SELECT @vAppID = appID from [ORNG.].Apps where Url like '%/MediaLinks.xml' 
DECLARE @curLinks CURSOR
SET @curLinks = CURSOR FOR select distinct NodeID  
 from [ORNG.].[AppData] where appID = @vAppID 
OPEN @curLinks
	FETCH NEXT
	FROM @curLinks INTO @vNodeID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [ORNG.].[RemoveAppFromAgent] @SubjectID=@vNodeID, @AppID=@vAppID
		FETCH NEXT
		FROM @curLinks INTO @vNodeID
	END
CLOSE @curLinks
DEALLOCATE @curLinks


-- disable gadget
declare @vAppID int
select @vAppID = AppID from [ORNG.].[Apps] where Url like '%/MediaLinks.xml' 
exec [ORNG.].[RemoveAppFromOntology] @AppID=@vAppID 

UPDATE [ORNG.].Apps SET [Enabled] = 0 WHERE AppID=@vAppID 

-- STOP

-- delete filters
DECLARE @PersonFilterID INT
SELECT @PersonFilterID = PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'In The News';

-- check this, if any return then STOP
SELECT * FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @PersonFilterID;
--DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = 13;
DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'In The News';
delete from [Profile.Import].[PersonFilterFlag] where personfilter = 'In The News';


