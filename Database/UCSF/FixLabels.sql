select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'mailing address';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Mailing Address' where _PropertyLabel = 'mailing address';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'email address';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Email Address' where _PropertyLabel = 'email address';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'photo';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Photo' where _PropertyLabel = 'photo';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'awards and honors';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Awards and Honors' where _PropertyLabel = 'awards and honors';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'overview';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Overview' where _PropertyLabel = 'overview';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'keywords' or _PropertyLabel = 'interests';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Interests' where _PropertyLabel = 'keywords';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'selected publications';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Publications' where _PropertyLabel = 'selected publications';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'principal investigator on';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'NIH Awarded Grants' where _PropertyLabel = 'principal investigator on';

SELECT * from [Ontology.].[ClassProperty] where _PropertyLabel = 'has ORNG Application Instance';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Add-ons' where _PropertyLabel = 'has ORNG Application Instance';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'education and training';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Education and Training' where _PropertyLabel = 'education and training';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'RSS Application';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Research Blogs and Feeds' where _PropertyLabel = 'RSS Application';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'research activities and funding';
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Research Activities and Funding' where _PropertyLabel = 'research activities and funding';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'groups'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Groups' where _PropertyLabel = 'groups';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'welcome'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Welcome' where _PropertyLabel = 'welcome';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'about us'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'About Us' where _PropertyLabel = 'about us';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'group settings'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Visibility and End Date' where _PropertyLabel = 'group settings';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'group managers'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Managers' where _PropertyLabel = 'group managers';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'contact information'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Contact Information' where _PropertyLabel = 'contact information';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'members'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Members' where _PropertyLabel = 'members';

-- New native things in 3.0
select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'media links'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'In The News' where _PropertyLabel = 'media links';

select * from [Ontology.].[ClassProperty] where _PropertyLabel = 'webpage'
update [Ontology.].[ClassProperty] set _PropertyLabel = 'Websites' where _PropertyLabel = 'webpage';




