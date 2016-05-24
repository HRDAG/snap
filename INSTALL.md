# Install snap[^1]

`snap` is short for snapshot

This file describes how to install and use snap (and should eventually describe how to install snapserv).

## 0) Working with HRDAG snap repository

If you'll be accessing the HRDAG snap repository, you should first read:

	https://github.com/HRDAG/resource-utils/blob/master/faqs/data-hacking-on-server.md

and especially follow the instructions in the "SSH stuff" section.

## 1) Define your `git` path

You need to make sure you have defined HRDAG_GIT_HOME in your ~/.bash_profile.  For example, you would add this line:

	export HRDAG_GIT_HOME=~/git

if you created your git workspace by running a command like:

	mkdir -p ~/git

Afterwards, add HRDAG_GIT_HOME to your shell's environment by running the command:

	source ~/.bash_profile


## 2) Clone snap tree to your laptop

	cd $HRDAG_GIT_HOME
	git clone git@github.com:HRDAG/snap.git


## 3) Make it easy to run snap on your laptop

You want to make it easy to run snap on your laptop (you do _not_ need to do this setup on HRDAG's snap server, it always has the latest version in everyone's PATH).

A good way is to "put" snap in your personal bin directory, by running:

	ln -sf ~/git/snap/bin/snap ~/bin/

and then making sure that your ~/.bash_profile contains a line like:

	PATH=~/bin:$PATH

and that you ran `source ~/.bash_profile` after adding that line.

If you don't want to have a personal `bin` directory, you can add snap to your PATH by adding a line like:

	PATH=$PATH:$HRDAG_GIT_HOME/snap/bin

to your ~/.bash_profile, and then running `source ~/.bash_profile`.

Either way, you can make sure snap is in your PATH by running:

	which snap


## 4) Configure `~/.ssh/config`

You need to add the line:

	SendEnv HRDAG_SNAP_VERSION

to the `Host *` stanza in your `~/.ssh/config` file, or else to the stanza of any server that hosts a snap repository.


## 5) snap alters .gitignore

The first time you run snap in a project tree, it will append the following lines to that project's .gitignore file:

	input/
	output/
	frozen/

to make sure that the directories saved in the snap repository aren't also saved in git.

## You're good to go!

If you're looking for info on snap semantics, have a look at the README



[^1]: ARG: The info here builds on an email from PB (2. Nov 2014) so that others can install and use snap. If anything is missing, feel free to add and expand. Note that README.md has more details about semantics and why we're using snap.
