/**********************************************************************
 ** acquire a lock (which could have been stale) in race-free manner **
 **********************************************************************/

/*

The Martus(tm) free, social justice documentation and
monitoring software. Copyright (C) 2002,2003, Beneficent
Technology, Inc. (Benetech).

Martus is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later
version with the additions and exceptions described in the
accompanying Martus license file entitled "license.txt".

It is distributed WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, including warranties of fitness of purpose or
merchantability.  See the accompanying Martus License and
GPL license for more details on the required license terms
for this software.

You should have received a copy of the GNU General Public
License along with this program; if not, write to the Free
Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.

*/

#define _GNU_SOURCE		/* want O_NOFOLLOW option to open(2) */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>		/* <asm-generic/errno-base.h> on Linux */
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <signal.h>
#include <string.h>

// ===========================================================================
// miscellaneous typedefs/constants/defines/etc
// ===========================================================================

const char lock_dir[] = "/var/lock";

// exit status is one byte wide; bash exit is >= 128 when died from signal
static const int lock_busy_exit_status =   1;
static const int   unknown_exit_status = 127;
static const int     usage_exit_status = 126;

typedef int bool;
static const bool False = 0;
static const bool True  = 1;

// ===========================================================================
// globals that are set once at startup
// ===========================================================================

const char *argv0;		/* our command name with path stripped */
const char *lock_file;
const char *lock_pid;

// ===========================================================================
// our user interface
// ===========================================================================

void
show_usage_and_exit(void)
{
    fprintf(stderr, "\n\
Usage: %s [-r] file [pid]\n\
   cd %s, put 'pid' (else parent's PID) into 'file', and exit with 0;\n\
      but, if 'file' already holds PID of another active process, exit with %d;\n\
      if there's any (other) kind of error, exit with > %d (typically errno).\n\
   To release the lock, use the -r option (or just delete 'file').\n\
\n\
   NOTE: This command is only suitable for local locks, not networked locks.\n\
\n\
   'file' is locked with flock before checking/writing 'pid', to avoid races.\n\
   To avoid security risks, this command will bomb if 'file' is a symlink.\n\
\n\
", argv0, lock_dir, lock_busy_exit_status, lock_busy_exit_status);

    exit(usage_exit_status);
}

// ===========================================================================

void
show_errno_and_exit(const char *system_call)
{
    char *errno_msg;

    if (errno == ELOOP && strcmp(system_call, "open") == 0)
	errno_msg = "unsafe for lockfile to be a symlink";
    else
	errno_msg = strerror(errno);

    if (!lock_file)
	lock_file = "";

    if (system_call)
	fprintf(stderr, "\n%s %s: %s: %s\n\n",
		argv0, lock_file, system_call, errno_msg);

    if (errno <= 1)		/* 1 means "lock is busy" */
	errno  = unknown_exit_status;

    exit(errno);
}

// ---------------------------------------------------------------------------

bool do_release;

void
parse_argv_setup_globals(int argc, char * const argv[])
{
    static char *cp;

    cp = strrchr(argv[0], '/');
    if (cp)
	argv0 = ++cp;
    else
	argv0 = argv[0];

    if (argc > 1 && strcmp(argv[1], "-r") == 0) {
	argv++;
	do_release = True;
    } else
	do_release = False;

    if (argc < 2 || argc > 3 || argv[1][0] == '-')
	show_usage_and_exit();

    lock_file = argv[1];

    lock_pid  = argv[2];
}

// ---------------------------------------------------------------------------

void
release_file_and_exit(void)
{
    if (access(lock_file, W_OK) == 0 && unlink(lock_file) == 0)
	exit(0);
    else
	show_errno_and_exit("unlink");
}

// ---------------------------------------------------------------------------

int
create_file_for_lock(void)
{
    int fd;

    if (chdir(lock_dir) < 0)
	show_errno_and_exit("chdir");

    // let umask control who can reclaim a stale lock
    fd = open(lock_file, O_RDWR | O_CREAT | O_NOFOLLOW, 0666);

    if (fd < 0)
	show_errno_and_exit("open");

    return(fd);
}

// ---------------------------------------------------------------------------

void
lock_file_or_exit(const int fd)
{
    if (flock(fd, LOCK_EX | LOCK_NB) == 0)
	return;
	    
    if (errno == EWOULDBLOCK) {
	printf("lock '%s' is busy\n", lock_file);
	exit(lock_busy_exit_status);
    }

    show_errno_and_exit("flock");
}

// ---------------------------------------------------------------------------

void
exit_if_file_holds_active_pid(const int fd)
{
    char line[16];
    pid_t lock_pid;

    if (read(fd, line, sizeof(line)) < 0)
	show_errno_and_exit("read");

    if (sscanf(line, "%d", &lock_pid) != 1)
	return;

    if (kill(lock_pid, 0) < 0) {
	if (errno == ESRCH)
	    return;

	// if EPERM, process exists (but isn't owned by us) so fall through
	if (errno != EPERM)
	    show_errno_and_exit("kill");
    }

    if (getppid() == lock_pid) {
	// don't send this to stderr, so easy to ignore
	printf("%s %s: already hold lock\n", argv0, lock_file);
	exit(0);
    } 

    printf("Process %d holds lock '%s'\n", lock_pid, lock_file);

    exit(lock_busy_exit_status);
}

// ---------------------------------------------------------------------------

void
write_pid_to_file(const int fd)
{
    char line[16];
    pid_t pid = (lock_pid) ? atoi(lock_pid) : getppid();

    if (lseek(fd, 0, SEEK_SET) < 0)
	show_errno_and_exit("lseek");

    if (ftruncate(fd, 0) < 0)
	show_errno_and_exit("ftruncate");
    
    // format per http://www.pathname.com/fhs/2.2/fhs-5.9.html
    sprintf(line, "%10d\n", pid);

    if ( write(fd, line, strlen(line)) != strlen(line) ) {
	int write_errno = errno;

	ftruncate(fd, 0);	/* delete possibly-partial PID */
	errno = write_errno;
	show_errno_and_exit("write");
    }
}

// ---------------------------------------------------------------------------

void
close_file(const int fd)
{
    if (close(fd) < 0) {
	int close_errno = errno;

	unlink(lock_file);	/* file contents might be mangled */
	errno = close_errno;
	show_errno_and_exit("close");
    }
}

// ---------------------------------------------------------------------------

int
main(int argc, char *argv[])
{
    int fd;

    parse_argv_setup_globals(argc, (char * const *)argv);

    if (do_release)
	release_file_and_exit();

    fd = create_file_for_lock();

    lock_file_or_exit(fd);

    exit_if_file_holds_active_pid(fd);

    write_pid_to_file(fd);

    close_file(fd);

    return(0);
}
