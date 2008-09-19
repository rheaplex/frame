= frame

http://github.com/robmyers/frame/

== DESCRIPTION:

A rails-style generator system for creating and managing digital art projects.

== FEATURES/PROBLEMS:

Not all initial functionality has been implemented or tested yet.

Waiting on liblicense being incorporated into more distros before adding 
Creative Commons license handling.

== SYNOPSIS:

Create a project:

> art_project test

Change to the project directory:

> cd test

Create a work:

> script/work first.svg

Edit it:

> inkscape preparatory/first.svg

Create various other works and edit them:

> script/work -c first.svg workX.svg
...

Decide some are good and some are bad:

> script/status --final work1.svg
> script/status --discard work2.svg
...

Make a release archive:

> script/release 0.0.1

make a web page:

> script/web

Have a rest, then start making more works.

== REQUIREMENTS:

Will ultimately rely on liblicense.

== INSTALL:

sudo gem install frame

== LICENSE:

frame - create and manage digital art project directory structures
Copyright (C) 2008 Rob Myers

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
