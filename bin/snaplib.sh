:

#     snap is a utility to store some directories on a server, versioned.
#
# Copyright (C) 2014-2017, Human Rights Data Analysis Group (HRDAG)
#     https://hrdag.org
#
# This file is part of snap.
#
# snap is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# snap is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with snap.  If not, see <http://www.gnu.org/licenses/>.

Version=0.4.18		# run Linux version of 'snap' if run as root
#
Version_required=0.2.18	# 'snap log' records had old revision not new one
Version_required=0.2.19	# when 'snap push', don't show 0B transfers
Version_required=0.2.20	# sort .snap/files-* just before we use them
Version_required=0.2.21	# can't hard-link snapshot not owned by us
Version_required=0.2.22	# show "workspace out-of-date" warning at end
Version_required=0.3.1	# 'snap push' now requires a commit message
Version_required=0.3.2	# correctly handle directory names with spaces
Version_required=0.4.1	# catch many errors, abort with user-friendly msg
Version_required=0.4.2	# be stricter with allowed tag names
Version_required=0.4.3	# update copyright dates
Version_required=0.4.4	# explain why a bad tag name is illegal
Version_required=0.4.5	# alert user if internal 'ssh' generates an error
Version_required=0.4.6	# must sort files-* files *after* append metadata
Version_required=0.4.7	# if snapserv error msg, show it (not rsync msg)
Version_required=0.4.8	# ensure user has write perms before attempt push
Version_required=0.4.9	# improve filter for snappable files
Version_required=0.4.10	# global snap config files moved into /etc/snap/
Version_required=0.4.11	# standardize access-denied error message
Version_required=0.4.12	# save "useless" test output to aid in debugging
Version_required=0.4.13	# improve PS4: show context when running 'set -x'
Version_required=0.4.14 # note/ subdirs now saved by 'snap', ignored by 'git'
Version_required=0.4.15 # work harder to ensure new project has a .snap/
Version_required=0.4.16 # don't push cache files
Version_required=0.4.17 # need *cache* files, but don't push .*cache* files
Version_required=0.4.18	# run Linux version of 'snap' if run as root

maintainer="Scott Weikart <sweikart@gmail.com>" # can over-ride in config file

default_snap_host=eleanor.hrdag.org

set -u					# error if expand unset variable

umask 02				# we use group perms for authorization

# PATH=/usr/local/bin:$PATH		# get symlink to different rsync

Run=					# caller can set (e.g. with getopts d)

# ----------------------------------------------------------------------------
# constants
# ----------------------------------------------------------------------------

# if command in /home/, precede by ~ (yourself) else ~other-user
PS4='+ $(echo $BASH_SOURCE | sed "s@^$HOME/@~/@; s@^/home/@~@; s@/.*/@ @")'
PS4+=' line ${LINENO-}, in ${FUNCNAME-}(): '
export PS4
readonly PS4

readonly rsync_max_compress_opt="--compress-level=9"
readonly rsync_output=.snap/rsync.log
# the --exclude patterns are duplicated in write_metadata
readonly rsync_client_opts="--verbose --partial
	   --recursive --links --hard-links --times --sparse --omit-dir-times
	   --exclude=$rsync_output*   --exclude=.DS_Store
	   --exclude=*~ --exclude=#*# --exclude=.#*"
# --server options that correspond to client's use of $rsync_opts;
#    -O is not used when --sender
readonly rsync_server_opts="-vlOHtrSe.is --partial"

# these subdirs are duplicated in /etc/snapback/exclude.txt
readonly snappable_subdirs="input output frozen note"

readonly true=t false=

if [[ $(uname) == Linux ]]
   then readonly is_linux=$true
   else readonly is_linux=$false
fi

readonly tmpdir=/tmp/$(id -nu); mkdir -m 0700 -p $tmpdir
our_name=${0##*/}			# caller can change this
readonly   _tmp=$tmpdir/$our_name.$$	# reserved for snaplib.sh
readonly  tmp_1=$tmpdir/$our_name-1.$$
readonly  tmp_2=$tmpdir/$our_name-2.$$
readonly  tmp_3=$tmpdir/$our_name-3.$$
readonly  tmp_4=$tmpdir/$our_name-4.$$
readonly  tmp_5=$tmpdir/$our_name-5.$$
readonly  tmp_6=$tmpdir/$our_name-6.$$
readonly  tmp_files="$_tmp $tmp_1 $tmp_2 $tmp_3 $tmp_4 $tmp_5 $tmp_6"

readonly date=$(date '+%a %m/%d %X %Z')

# ----------------------------------------------------------------------------
# generic helper functions
# ----------------------------------------------------------------------------

readonly is_snapserv=${who_am_i-}

have_cmd() { type -t "$@" &> /dev/null; }
run_cmd() {
	[[ $1 == -w ]] && { shift; local is_warn=$true; } || local is_warn=
	$Run "$@" && return 0
	local status=$?
	[[ $is_snapserv ]] &&
	log "  $* => $status"		# log defined in 'snapserv' command
	if [[ $is_warn ]]
	   then while [[ $1 != */* ]]
		    do	echo -n "$1 "
			shift
		done
		[[ $# != 0 ]] && { echo -n "$1 "; shift; }
		[[ $# != 0 ]] &&   echo -n "... "
		echo   "=> $status (probably not a problem)"
	   else	error "$* => $status"
	fi >&2
}

warn () {
	echo -e "\n$our_name: $*\n" >&2
	[[ $is_snapserv ]] && log "$@"
	return 1
}
error() { warn "$*"; exit 1; }

cd_() { cd "$@" || error "cd => $?"; [[ $Run ]] && echo "cd $*"; }

# ----------------------------------------------------------------------------

print_or_egrep_Usage_then_exit() {
	[[ ${1-} == -[hHk] ]] && shift	# strip help or keyword-search option
	[[ $# == 0 ]] && echo -e "$Usage" && exit 0
	echo "$Usage" | grep -i "$@"
	exit 0
}

# ----------------------------------------------------------------------------
# functions used by snap and snapserv
# ----------------------------------------------------------------------------

readonly strace="strace -f -o /tmp/$LOGNAME/strace.log" # can prefix to rsync

if [[ $is_linux ]]
   then readonly ls_opts="--time-style=long-iso" # GNU
   else readonly ls_opts="-T"			 # Darwin / OS X
fi

# toss mode and link-count, then toss group and size
readonly _ls_regexp_filter='s/^[-a-z.]+ +[0-9]+ +//; s/ [^ ]+ +[0-9]+ +/  /'
#
[[ $is_linux ]] && {
iso_ll_field_selector() {
	# this is the GNU version, whose ls -l --time-style=long-iso is e.g.:
	# lrwxrwxrwx  1 scott EX     3 2014-05-14 Wed 15:56:57 label -> s18/
	sed --regexp-extended -e "$_ls_regexp_filter" -e 's/(:.. )/\1 /'
	}
} || {
iso_ll_field_selector() {
	# this is the Darwin / OS X version, whose ls -lT output looks like:
	# lrwxrwxrwx  33 pball  staff  1122 Mar 10 10:59:05 2016 label -> s10/
	sed -E -e "$_ls_regexp_filter" -e 's/([A-Z].+) ([0-9]{4})/\2 \1  /'
	}
}

abort_if_bad_version_format() {
	local variable_name=$1

	local version=${!variable_name}

	[[ $version == *.*.* && ! $version == *.*.*.* ]] ||
	   error "$variable_name's value needs to have exactly 3 segments"

	[[ $version != *[^.0-9]* ]] ||
	   error "$variable_name's segments must be all digits"
}
abort_if_bad_version_format Version
abort_if_bad_version_format Version_required
#
declare -i version_num
 set_version_num() {
	local version=$1

	set -- $(echo $version | tr . ' ')
	let version_num="( ( ($1 * 1000) + $2) * 1000 ) + $3"
}

# convert_snap_metadata assumes that .snap.sha1 is renamed last
readonly old_name__new_name__pairs="
.snap.config		.snap/config
.snap.log		.snap/push.log
.snap.rev		.snap/revision
.snap.rm		.snap/paths-to-delete
.snap.pre-push		.snap/files-pre-push
.snap.local		.snap/files-local
.snap.local.sha1	.snap/files-local.sha1
.snap.orig		.snap/files-repo
.snap.sha1		.snap/files-repo.sha1

.snap/config		.snap/config.sh
"

convert_snap_metadata() {
	[[ $old_name__new_name__pairs ]] || return 1
	[[ -f .snap.sha1 || -f .snap/config ]] || return 1 # already converted?

	[[ -f .snap ]] && run_cmd mv .snap .snap.orig
	run_cmd mkdir -p .snap
	local      old_name  new_name
	echo     "$old_name__new_name__pairs" |
	while read old_name  new_name
	   do	[[ $old_name && $new_name ]] || continue
		[[ -e $old_name ]] || continue
		run_cmd mv $old_name $new_name
	done
	local file
	for file in .snap/*.sha1
	    do	[[ -s $file ]] || continue
		run_cmd sed -i~ \
		   's@.snap.local$@files-local@; s@.snap$@files-repo@' $file
	done
	return 0
}

# ----------------------------------------------------------------------------

source_config() {
	local file=$1

	if [[ -s $file ]]
	   then	source $file || error "$file ended with non-0 status"
		[[ ${action-} == orig* ]] && echo "sourced $file"
	   else [[ ${action-} == orig* ]] && echo "empty:  $file"
		return 1
	fi

	return 0
}

# ----------------------------------------------------------------------------

compute_metadata() {

	expand > $_tmp <<-\EOF
	import sys, os, os.path, time
	from os.path import getsize, getmtime

	def timestr(secs):
	    return time.strftime( '%Y-%m-%d %H:%M:%S UTC', time.gmtime(secs) )

	for path in sys.stdin:
	    path = path.rstrip()
	    if os.path.islink(path):
	        print("{} -> {}".format(path, os.readlink(path)))
	    else:
	        # snap's files_to_paths assumes 2 spaces after filename
	        print("{}  {:,}B  {}".format(path,   getsize (path),
					     timestr(getmtime(path))))
	EOF

	[[ -s  $_tmp ]] || error "no space on $(dirname $_tmp)/ ?"
	python $_tmp    || error "$snapserv_root/ out of disk space?"
	rm $_tmp
}

# -------------------------------------------------------

if have_cmd sha1sum
   then readonly sha_cmd=sha1sum
   else readonly sha_cmd=shasum
fi

write_metadata() {

	if [[ $our_name != snapserv ]]
	   then local  metadata_file=.snap/files-local
	   else local  metadata_file=.snap/files-repo
		# these could be hardlinked from an older snapshot
		rm -f $metadata_file $metadata_file.sha1
	fi
	run_cmd mkdir -p .snap	  # might be fixing a half-initialized project

	[[ ${Run-} ]] && metadata_file=/dev/tty
	local dir grep_opts=
	for dir in $snappable_subdirs
	    do	grep_opts="$grep_opts -e ^$dir/ -e /$dir/"
	done
	set -- *
	[[ $* != "*" ]] || error "$PWD workspace is empty"
	# the -path arg & -name patterns are duplicated in rsync_client_opts
	find * \( -type f -o -type l \) \
	     ! -path "$rsync_output*"   ! -name .DS_Store \
	     ! -name '.~lock.*#' \
	     ! -name '*~' ! -name '#*#' ! -name '.#*' | # ignore emacs temps
	  grep $grep_opts | compute_metadata | sort > $metadata_file ||
	     error "$FUNCNAME -> $?: $snapserv_root/ out of disk space??"
	[[ ${PIPESTATUS[0]} == 0 ]] || error "must first fix the above error"

	if [[ ! ${Run-} ]]
	   then cd_ .snap
		metadata_file=${metadata_file#.snap/}
		$sha_cmd $metadata_file > $metadata_file.sha1
		cd_ ..
	fi
	true
}

# -------------------------------------------------------

sort_files_in_place() {

	local file
	for file
	    do	[[ -s $file ]] || continue
		[[ $file != *.sha* ]] || continue
		$Run sort --check  $file && continue
		$Run sort --output=$file $file || error "$FUNCNAME $file"
		[[ -e $file.sha1 && ! ${Run-} ]] && $sha_cmd $file > $file.sha1
	done
}

# ----------------------------------------------------------------------------

# this is like rm-untagged-snapshots in snapback
show_tagged_snaps() {

	for snap in *
	    do	[[ $snap != '*' ]] || continue
		[[ $snap == s[0-9]* ]] && continue # actual snapshot?
		[[ -L $snap ]] || error "$PWD/$snap is not a tag"
		echo $PWD/$snap
		tagged_snapshot=$(readlink $snap)
		echo $PWD/$tagged_snapshot
	done
}
