# Snap

Snap is a utility to store some directories on a server, versioned.

Copyright (c) Human Rights Data Analysis Group, 2014

Snap enables the parallel management of big data files within a git
project. Git is bad at keeping data files for the following reasons:

* Data files are often stored as compressed binary representations of floats or complicated data structures.

* git stores every change, and even small substantive changes tend to change every byte in a compressed binary format. This means that every recalculation can change the whole file, which would require that entire file be stored in each commit.

* We don't need the version of every data file. Data files are produced by code, and the code should be able to reproduce the data files.

* We need the data files for two reasons: (a) **short-term** we need to be able to transfer the files from one user to another for testing. (b) **long-term** we need the data files for archival purposes. Once a project has been left for a year or two, it can be enormously difficult to get the software running again. In order to know what happened in intermediate steps of the process, we cannot depend on re-running the code, so we need the data files.



# A bit more detail.

"snap" is short for "snapshot." The point of snap is to separate the version control of data from source code. Version control systems are not good at handling big files (i.e., >1MB), so we don't keep them on github. Furthermore, much of our data is confidential, and we don't want to put it on a github server. Using snap for data, and github for code, we are able to segregate most (maybe all) of the actual data so it continues to live on our secure server at Benetech (maintained by Scott) rather than in git.



## How to use snap

Our data organization framework works for this problem. First, we tell git to ignore all the input/ and output/ directories by adding these lines to the .gitignore file (located at the top of a repository, like 

  $HRDAG_GIT_HOME/SY/.gitignore 

). The gitignore has to be set before starting to use snap. This means that input/ and output/ are NOT IN GIT. Keep this in mind.

Second, confirm with git that the input/ and output/ are not in github's repo. You can look at the github repo through the web interface. 

Third, put the data into snap. At the point you want to put data into snap, give this command (like git, you can be anywhere in the tree, snap works on the whole tree):

  snap push -m "this is my commit message for snap" 

and snap will tell you a revision number. To get data from snap, say 

  snap pull 

I recommend using `snap log` to see what's going on. Here's SY:

pball@piglet:~/git/SY 
   $ snap log
SY/s10 | meganp | 2014-10-28 20:52:44 UTC (Tue) | --
SY/s9 | meganp | 2014-10-28 20:47:01 UTC (Tue) | --
SY/s8 | meganp | 2014-10-24 22:01:12 UTC (Fri) | --
SY/s7 | meganp | 2014-10-24 20:58:23 UTC (Fri) | --
SY/s6 | meganp | 2014-10-23 22:51:59 UTC (Thu) | --
SY/s5 | meganp | 2014-10-22 21:37:07 UTC (Wed) | --
SY/s4 | meganp | 2014-10-22 21:25:04 UTC (Wed) | --
SY/s3 | meganp | 2014-09-29 20:13:38 UTC (Mon) | --
SY/s2 | meganp | 2014-09-25 21:37:48 UTC (Thu) | --
SY/s1 | meganp | 2014-09-25 21:36:35 UTC (Thu) | --
| pball | 2014-07-16 21:06:56 UTC (Wed) | pair labeling notebook in place

Hmm, it seems Megan isn't using snap commit messages! You can also add a tag to a snap push, which is like an additional kind of comment. The point of tags is to be the same as a git tag, which we'd use any time we send results outside the team. 

http://git-scm.com/book/en/v2/Git-Basics-Tagging

for CO, here are the tags:

pball@piglet:~/git/CO
   $ git tag
v0.1
v0.2
v0.3
v1.0
v1.01
v1.1
v2.0
v3.0

now you can look at one tag: 

pball@piglet:~/git/CO
   $ git show v3.0
tag v3.0
Tagger: P. Ball <pball@hrdag.org>
Date:   Mon Sep 15 22:51:32 2014 -0700

new estimates and final memo sent to OHCHR

commit baa4b95b1201a5c5c1021d8ab8db66144e6cd69b
Author: P. Ball <pball@hrdag.org>
Date:   Mon Sep 15 22:50:11 2014 -0700

   version sent.

diff --git a/MSE/report1/src/CO-OHCHR-estimates-A-July2014.Rnw b/MSE/report1/src/CO-OHCHR-estimates-A-July2014.Rnw
index 0ac4710..55078ee 100644
--- a/MSE/report1/src/CO-OHCHR-estimates-A-July2014.Rnw
+++ b/MSE/report1/src/CO-OHCHR-estimates-A-July2014.Rnw
@@ -27,9 +27,9 @@
\usepackage{graphicx}
\usepackage{subfig}


and now look at snap's tags:

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


You can see that v3.0 points at s36. This allows you to reconstruct the code and the data at the point we sent it to OHCHR back in September. 

Please let me know if this is enough detail or you need more -- PB. 


* to check out a specific snap version (e.g., the SV tree at version 15) in a temp dir, say `cd /tmp; snap pull SV/s15`
