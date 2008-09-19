#!/bin/env ruby

#    frame - create and manage digital art project directory structures
#    Copyright (C) 2008 Rob Myers
# 
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
# 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#    GNU General Public License for more details.
# 
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.

require 'fileutils'

# Clean up

if File.exists? './test_project'
  FileUtils.remove_entry_secure './test_project'
end

# Test making a project

Kernel.system '../bin/frame', 'test_project' 
raise "Couldn't make test project." unless File.exist? './test_project'


# Test Work

Kernel.system 'test_project/script/work', 'work.svg' 
raise "Couldn't make test svg work." unless 
  File.exist? './test_project/preparatory/work.svg'

Kernel.system 'test_project/script/work', '-c', 'work.svg', 'work2.svg'
raise "Couldn't make relative test svg work copy." unless 
  File.exist? './test_project/preparatory/work2.svg'

Kernel.system 'test_project/script/work', '-c', 
              './test_project/preparatory/work2.svg', 'work3.svg'
raise "Couldn't make absolute test svg work copy." unless 
  File.exist? './test_project/preparatory/work3.svg'


# Test Move

Kernel.system 'test_project/script/move', '--discard', 'work2.svg'
raise "Couldn't move work to discard." unless 
  File.exist? './test_project/final/work2.svg'

Kernel.system 'test_project/script/move', '--final', 'work3.svg'
raise "Couldn't move work to final." unless 
  File.exist? './test_project/final/work3.svg'

Kernel.system 'test_project/script/move', '--discard', 'work.svg'
Kernel.system 'test_project/script/move', '--preparatory', 'work.svg'
raise "Couldn't move work back to preparatory." unless 
  File.exist? './test_project/final/work.svg'


# Test Release


# test Web


# Test Subversion


# Test Git
