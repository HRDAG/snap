# Snap

Snap is a utility to store some directories on a server, versioned.

Copyright (c) Human Rights Data Analysis Group, 2014

Snap enables the parallel management of big data files within a git
project. Git is bad at keeping data files for the following reasons:

* Data files are often stored as compressed binary representations of floats or complicated data structures.

* git stores every change, and even small substantive changes tend to change every byte in a compressed binary format. This means that every recalculation can change the whole file, which would require that entire file be stored in each commit.

* We don't need the version of every data file. Data files are produced by code, and the code should be able to reproduce the data files.

* We need the data files for two reasons: (a) **short-term** we need to be able to transfer the files from one user to another for testing. (b) **long-term** we need the data files for archival purposes. Once a project has been left for a year or two, it can be enormously difficult to get the software running again. In order to know what happened in intermediate steps of the process, we cannot depend on re-running the code, so we need the data files.


## snap semantics

* to check out a specific snap version (e.g., the SV tree at version 15) in a temp dir, say `cd /tmp; snap pull SV/s15`
