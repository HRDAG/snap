# Snap

Snap is a utility to store some directories on a server, versioned.

Copyright (c) Human Rights Data Analysis Group, 2014

Snap enables the parallel management of big data files within a git
project. Git is bad at keeping data files for the following reasons:

* Data files are often stored as compressed binary representations of floats or complicated data structures.

* git stores every change, and even small substantive changes tend to change every byte in a compressed binary format. This means that every recalculation can change the whole file, which would require that entire file be stored in each commit.

* We don't need the version of every data file. Data files are produced by code, and the code should be able to reproduce the data files.

* We need the data files for two reasons: (a) **short-term** we need to be able to transfer the files from one user to another for testing. (b) **long-term** we need the data files for archival purposes. Once a project has been left for a year or two, it can be enormously difficult to get the software running again. In order to know what happened in intermediate steps of the process, we cannot depend on re-running the code, so we need the data files.



# A bit more detail.[^1]
**snap** is short for "snapshot." The point of snap is to separate the version control of data from source code. Version control systems are not good at handling big files (i.e., >1MB), so we don't keep them on github. Furthermore, much of our data is confidential, and we don't want to put it on a github server. Using snap for data, and github for code, we are able to segregate most (maybe all) of the actual data so it continues to live on our secure server at Benetech (maintained by Scott) rather than in git.



# How to: snap semantics

Build your project as usual (input/ src/ output/ etc. )

When you're ready (i.e. have some data in input or output), put it into snap. The syntax is simliar to git and can be used anything within a tree (like git):

### push data to snap

  `snap push -m "this is my commit message for snap"` 

Uploading can take a while if you have a lot of data. Once it's done, snap will tell you a revision number. 


### pull data from snap

  `snap pull` 


### check snapped data versions:

Like in svn etc, use:

	`snap log`

### snap tags

Like in git, you can not only add snap messages, you can also use tags (see <http://git-scm.com/book/en/v2/Git-Basics-Tagging>). Tags are useful when you want to keep track of certain data versions (e.g. "v1.2 as sent to OHCHR") 

Here is an example from PB of snap tags used in the CO project:



	pball@piglet:~/git/CO 
   		$ snap tags
	lrwxrwxrwx. 1 kristianl CO    3 Oct  8 14:09 CO/HEAD -> s37
	lrwxrwxrwx. 1 pball     CO    2 May 21 18:45 CO/v0.1 -> s7
	lrwxrwxrwx. 1 pball     CO    3 Jun 30 21:04 CO/v0.2 -> s19
	lrwxrwxrwx. 1 pball     CO    3 Jul  2 23:14 CO/v0.3 -> s20
	lrwxrwxrwx. 1 pball     CO    3 Jul  8 02:35 CO/v1.0 -> s22
	lrwxrwxrwx. 1 pball     CO    3 Jul 13 17:34 CO/v1.01 -> s25
	lrwxrwxrwx. 1 pball     CO    3 Jul 20 10:28 CO/v1.1 -> s28
	lrwxrwxrwx. 1 pball     CO    3 Jul 31 20:21 CO/v2.0 -> s32
	lrwxrwxrwx. 1 pball     CO    3 Sep 15 22:59 CO/v3.0 -> s36


You can see that v3.0 points at s36. This allows you to reconstruct the code and the data at the point PB sent it to OHCHR back in September. 

### check out a specific snap version:

You can check out specific versions of the data. For example, after looking at `snap log` or `snap tags`, you might want to look at version 15 in the SV tree, then you can put that data into a temporary directory:

	cd /tmp
	snap pull SV/s15 

## open questions:

- What to we do with hand/ files? are they code (in most projects this is just where we keep CONSTANTS files), or are they data (e.g. when we get data in weird formats, we tend to import it through a step of opening the files in hand and manually configuring stuff). wee need to think about this.




[^1]: ARG: The info here builds on an email from PB (2. Nov 2014) so that others can install and use snap. If anything is missing, feel free to add and expand. Note that README.md has more details about semantics and why we’re using snap.