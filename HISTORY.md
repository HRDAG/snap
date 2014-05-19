# Snap

v0.2.9 was released and tagged Mon 19 May 2014. This is pre-alpha, nearly ready for alpha release to team. All development to this point done by Scott Weikart; original specs by Patrick Ball.

This is the svn history before snap was moved from svn to github
================================================================

------------------------------------------------------------------------
r4130 | scott | 2014-05-15 17:33:03 -0700 (Thu, 15 May 2014) | 1 line

snap has been moved to github, so store the svn version with log and diffs into the Attic
------------------------------------------------------------------------
r4129 | scott | 2014-05-14 16:58:39 -0700 (Wed, 14 May 2014) | 1 line

Can pull arbitrary snapshot.  Can show tags for arbitrary project.
------------------------------------------------------------------------
r4128 | scott | 2014-05-14 16:01:57 -0700 (Wed, 14 May 2014) | 3 lines

snaplib.sh defines snappable_subdirs="input output frozen", and all the code
  operates off $snappable_subdirs.  Make sure that each of these subdirs is in
  the user's .gitignore
------------------------------------------------------------------------
r4127 | scott | 2014-05-14 11:17:01 -0700 (Wed, 14 May 2014) | 1 line

report error if user specifies comment without -m option
------------------------------------------------------------------------
r4126 | scott | 2014-05-14 09:21:24 -0700 (Wed, 14 May 2014) | 1 line

OS X compatibility fix
------------------------------------------------------------------------
r4125 | scott | 2014-05-13 22:56:49 -0700 (Tue, 13 May 2014) | 11 lines

At startup, 'snap' sources .snap/config if it exists; you can set snap_host in
  this file.  .snap/config is pushed the repo and pulled by the next user; this
  works well for snap_host; but if we add personalization variables, we may
  need a .snap/config.local
Can now pull a snapshot that's not HEAD, and run various commands when not in a
  git workspace (by specifying the project name as an argument).
Make sure that 'snap log' always shows full log.
All the .snap* files were moved into .snap/ and renamed; much internal renaming
  to go along with it.  Make changes for clarity and correctness, and add
  comments to explain odd or implied situations.
Some stuff that's not shared was moved out of snaplib.sh
------------------------------------------------------------------------
r4124 | scott | 2014-05-12 00:04:26 -0700 (Mon, 12 May 2014) | 1 line

don't hide spurious results of internal rsync
------------------------------------------------------------------------
r4123 | scott | 2014-05-10 21:08:40 -0700 (Sat, 10 May 2014) | 2 lines

version 1.6, snap push: fix propagation of deletes from local workspace into
  repo.
------------------------------------------------------------------------
r4122 | scott | 2014-05-10 19:35:36 -0700 (Sat, 10 May 2014) | 2 lines

version 1.5, snap pull: if the user chose to propagate (some) deletes from the
  repo, delete empty directories that contained those files.
------------------------------------------------------------------------
r4121 | scott | 2014-05-10 18:37:07 -0700 (Sat, 10 May 2014) | 3 lines

version 1.4, snap pull: if the most recent push(es) deleted files from the
  repo, and those files still exist locally, ask the user if they'd like to
  delete them.
------------------------------------------------------------------------
r4120 | scott | 2014-05-09 19:28:44 -0700 (Fri, 09 May 2014) | 4 lines

snap push: if the local user deleted some snap'ped files, write their paths to
  .snap.rm, so they can be deleted on the server (along with any empty
  directories).
snap tag: fix a fatal bug.
------------------------------------------------------------------------
r4119 | scott | 2014-05-09 17:23:23 -0700 (Fri, 09 May 2014) | 1 line

snap log: simplify logic
------------------------------------------------------------------------
r4117 | scott | 2014-05-09 12:38:55 -0700 (Fri, 09 May 2014) | 1 line

we use group perms for authorization: make local snappable files group-accessible
------------------------------------------------------------------------
r4116 | scott | 2014-05-08 21:09:37 -0700 (Thu, 08 May 2014) | 6 lines

Don't push emacs temp files to the server.
Make sure files pushed to server are saved as group-accessible, since we use
  group perms for authorization.
Conflict resolution: if someone modifies a file and pushes it, and you modify
  the same file before doing a pull, don't modify the file but warn the user
  (once) that you're ignoring the file in the repo.
------------------------------------------------------------------------
r4115 | scott | 2014-05-08 16:18:14 -0700 (Thu, 08 May 2014) | 1 line

refactoring to prepare for handling conflicts
------------------------------------------------------------------------
r4114 | scott | 2014-05-08 15:20:30 -0700 (Thu, 08 May 2014) | 1 line

snap log: only pull a new .snap.log if we're not HEAD
------------------------------------------------------------------------
r4113 | scott | 2014-05-08 14:42:13 -0700 (Thu, 08 May 2014) | 2 lines

snap push: always write a one-line log record, even if there's no comment.
snap log: pull HEAD/.snap.log, then show its lines in reverse order.
------------------------------------------------------------------------
r4112 | scott | 2014-05-08 12:51:14 -0700 (Thu, 08 May 2014) | 1 line

snap push: clean up restart code
------------------------------------------------------------------------
r4111 | scott | 2014-05-08 11:51:48 -0700 (Thu, 08 May 2014) | 1 line

snap push: automatically restart anytime rsync reports 'connection unexpectedly closed'
------------------------------------------------------------------------
r4110 | scott | 2014-05-08 11:30:39 -0700 (Thu, 08 May 2014) | 1 line

snap push: make restart more robust; be quiet when grab .snap* files afterward.
------------------------------------------------------------------------
r4109 | scott | 2014-05-07 22:45:25 -0700 (Wed, 07 May 2014) | 1 line

added a bunch of error handling
------------------------------------------------------------------------
r4108 | scott | 2014-05-07 22:05:13 -0700 (Wed, 07 May 2014) | 1 line

fix for Darwin
------------------------------------------------------------------------
r4107 | scott | 2014-05-07 21:35:07 -0700 (Wed, 07 May 2014) | 1 line

Support 'snap push -m msg' and 'snap push -F msg-file'.
------------------------------------------------------------------------
r4106 | scott | 2014-05-07 16:53:26 -0700 (Wed, 07 May 2014) | 1 line

warn user when restart after Broken pipe
------------------------------------------------------------------------
r4105 | scott | 2014-05-07 16:16:39 -0700 (Wed, 07 May 2014) | 1 line

work with older versions of bash
------------------------------------------------------------------------
r4104 | scott | 2014-05-07 14:35:27 -0700 (Wed, 07 May 2014) | 1 line

delete tmp files (unless an error occurs)
------------------------------------------------------------------------
r4103 | scott | 2014-05-07 13:25:42 -0700 (Wed, 07 May 2014) | 1 line

make it more clear when push succeeds
------------------------------------------------------------------------
r4102 | scott | 2014-05-07 13:19:30 -0700 (Wed, 07 May 2014) | 2 lines

Each time the 'snap push' rsync fails with 'Write failed: Broken pipe', repeat
  the rsync.
------------------------------------------------------------------------
r4101 | scott | 2014-05-07 12:38:02 -0700 (Wed, 07 May 2014) | 1 line

Have to kill any hanging rsync commands _before_ we try to get the lock.
------------------------------------------------------------------------
r4100 | scott | 2014-05-07 12:02:07 -0700 (Wed, 07 May 2014) | 1 line

if this user has an old rsync command running, kill it along with its ssh connection
------------------------------------------------------------------------
r4099 | scott | 2014-05-07 11:23:39 -0700 (Wed, 07 May 2014) | 1 line

Correctly handle first push (i.e. empty repo).
------------------------------------------------------------------------
r4098 | scott | 2014-05-07 10:04:41 -0700 (Wed, 07 May 2014) | 2 lines

Make 'snap push' restartable, by maintaining a per-user temporary head.  And be
  sure we don't lose HEAD from an inopportune crash.
------------------------------------------------------------------------
r4097 | scott | 2014-05-06 20:06:47 -0700 (Tue, 06 May 2014) | 1 line

make sure we're using maximum compression
------------------------------------------------------------------------
r4096 | scott | 2014-05-06 20:00:13 -0700 (Tue, 06 May 2014) | 1 line

pass --compress to rsync
------------------------------------------------------------------------
r4095 | scott | 2014-05-06 18:17:30 -0700 (Tue, 06 May 2014) | 1 line

be less restrictive with 'rm' authorization
------------------------------------------------------------------------
r4094 | scott | 2014-05-06 17:55:02 -0700 (Tue, 06 May 2014) | 4 lines

Make sure user can't 'snap rm *'.
Now only works with git, i.e. root of project workspace is the directory that
  contains .git/
Only push input/, output/ and frozen/
------------------------------------------------------------------------
r4093 | scott | 2014-05-06 11:34:05 -0700 (Tue, 06 May 2014) | 1 line

snapserv needs lockpid in its PATH
------------------------------------------------------------------------
r4092 | scott | 2014-05-04 20:10:13 -0700 (Sun, 04 May 2014) | 1 line

Implement 'snap status'.  When doing a pull, skip repo files that are older than the corresponding file in the current workspace.
------------------------------------------------------------------------
r4091 | scott | 2014-05-04 10:24:44 -0700 (Sun, 04 May 2014) | 1 line

clean up naming
------------------------------------------------------------------------
r4090 | scott | 2014-05-04 09:46:57 -0700 (Sun, 04 May 2014) | 1 line

improve detection of the root of the project directory
------------------------------------------------------------------------
r4089 | scott | 2014-05-04 09:33:24 -0700 (Sun, 04 May 2014) | 1 line

Don't use extglob, Darwin's bash doesn't like it
------------------------------------------------------------------------
r4088 | scott | 2014-05-03 21:04:22 -0700 (Sat, 03 May 2014) | 1 line

set extglob for Darwin
------------------------------------------------------------------------
r4087 | scott | 2014-05-03 19:15:12 -0700 (Sat, 03 May 2014) | 1 line

full set of functionality that requires communication with server
------------------------------------------------------------------------
r4086 | pball | 2014-05-03 10:41:41 -0700 (Sat, 03 May 2014) | 1 line

more unbalanced parens fixed
------------------------------------------------------------------------
r4085 | scott | 2014-05-03 10:34:48 -0700 (Sat, 03 May 2014) | 1 line

fix for Darwin; balance parantheses
------------------------------------------------------------------------
r4084 | scott | 2014-05-03 10:19:56 -0700 (Sat, 03 May 2014) | 1 line

make debugging easier
------------------------------------------------------------------------
r4083 | pball | 2014-05-03 10:12:49 -0700 (Sat, 03 May 2014) | 1 line

changed print semantics in snapserv
------------------------------------------------------------------------
r4082 | scott | 2014-05-02 22:01:38 -0700 (Fri, 02 May 2014) | 1 line

a work in progress, only partly debugged
------------------------------------------------------------------------
