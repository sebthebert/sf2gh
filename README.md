sf2gh
=====

SourceForge to GitHub migration tool

### Requirements

#### SourceForge

You need to have an export of your SourceForge Project.  
This export can be done in the **Admin/Export** section of your project. (https://sourceforge.net/p/your_project/admin/export)  
Then you need to unzip your export and rename it to **projectname-backup/**

#### GitHub

You need to have a valid [GitHub token](https://help.github.com/articles/creating-an-access-token-for-command-line-use) to access your GitHub account.


### Usage

```
sf2gh.pl --project <sf_project_name> 
	   --tracker <bugs|feature-requests|patches|support-requests>
	   --ghtoken <github_token> --ghuser <github_user> --ghrepo <github_repo>
	   [ --exclude <list_of_ids_to_exclude> ]
```
