# Install snap[^1]
Snap is short for snapshot 

This file describes how to install and use snap (and should eventually describe how to install snapserv).

## 1) Define your GIT path

You need to make sure you have defined $HRDAG_GIT_HOME in your ~/.bash_profile. 

For example this could be:

	export HRDAG_GIT_HOME=$HOME/GIT


Next, you need to add snap to your path in your ~/.bash_profile. For example:

	PATH=$PATH:$HRDAG_GIT_HOME/snap/bin

## 2) Clone snap tree

	 cd "$HRDAG_GIT_HOME" 
 	 git clone git@github.com:HRDAG/snap.git


## 3) set .gitignore

Before you use snap in a new project tree, make sure you have told .gitignore **not** to sync input/ and output/ - these should go into snap, not into git. For example, the SY tree currently has the following .gitignore:

	## files to be ignored in SY tree (ARG 2014-11-05)
	# ignore tmp files
	\~*
	*~

	.Rhistory

	# ignore snap metadata
	.snap*

	# ignore the data directories
	input/
	output/
	frozen/
 
Now that you've set .gitignore these folders and files won't be included in any syncs with Github, so you don't have to worry about them anymore.
 
Confirm with git that the input/ and output/ are not in github's repo. You can look at the github repo through the web interface. 
 
### you're good to go. If you're looking for info on snap semantics, have a look at the README



[^1]: ARG: The info here builds on an email from PB (2. Nov 2014) so that others can install and use snap. If anything is missing, feel free to add and expand. Note that README.md has more details about semantics and why we're using snap.
