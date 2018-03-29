all: lockpid

# The Martus(tm) free, social justice documentation and
# monitoring software. Copyright (C) 2002,2003, Beneficent
# Technology, Inc. (Benetech).
# 
# Martus is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later
# version with the additions and exceptions described in the
# accompanying Martus license file entitled "license.txt".
# 
# It is distributed WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, including warranties of fitness of purpose or
# merchantability.  See the accompanying Martus License and
# GPL license for more details on the required license terms
# for this software.
# 
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.


# to debug (if add any trace code), run as: TRACE=-DTRACE make
lockpid: lockpid.c
	$(CC) $(TRACE) -Wall -Wno-unknown-pragmas -g -o $@ $@.c

 DESTDIR := /usr/local/martus/bin
DEST2DIR := /usr/local/bookshare/bin

install: lockpid
	@[[ lockpid -ot $(DESTDIR)/lockpid ]] && exit 0; \
	 install --verbose lockpid $(DESTDIR)
	@[[ $(DESTDIR)/lockpid -ef $(DEST2DIR)/lockpid ]] && exit 0; \
	 [[ ! -d $(DEST2DIR) ]] || ln --force $(DESTDIR)/lockpid $(DEST2DIR)

clean:
	rm -f a.out core *.o lockpid
