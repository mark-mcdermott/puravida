#!/bin/bash
# Copyright 2023 Mark McDermott
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# drop this file in /usr/bin/local (in finder hit cmd + shift + . if you don't see the hidden usr folder)
# run sudo chmod 755 puravida to give it the right permissions
# now you should be able to use this anywhere
# note: this is macOS specific because of the sed command - you can tweak it on linux. something like sed -i '$ d' $FILEPATH might work (untested)

# 🌴 usage 1: oneliner combining mkdir -p and touch. e.g., puravida dir_1/dir_2/file.txt
# 🌊 usage 2: create (optionally nested) directory and multiple files in it. e.g., puravida dir/nested_dir file1.txt file2.txt
# 🏖️ usage 3: create (optionally nested) directory a file in it with (optionally multiline) contents (last line must just say ~ and that's all) you paste in and hit enter.
#             e.g., puravida dir/file.txt ~ (and then it awaits your content paste ending in an ~ line)

# by mark mcdermott 7/6/23, https://markmcdermott.io
# lots of overkill comments in this small script because bash is essentially jibberish
# tests for this script available at https://gist.github.com/mark-mcdermott/7a0f28370e4dcc98808842c259813937

# if no arguments, print usage syntax
if [ $# -eq 0 ]; then
  >&2 echo -e "🌴 usage 1: oneliner combining mkdir -p and touch. e.g., \033[36mpuravida dir_1/dir_2/file.txt\033[m\n🌊 usage 2: create (optionally nested) directory and multiple files in it. e.g., \033[36mpuravida dir/nested_dir file1.txt file2.txt\033[m\n🏖️  usage 3: create (optionally nested) directory a file in it with (optionally multiline) contents (last line must just say ~ and that's all) you paste in and hit enter.\n            e.g., \033[36mpuravida dir/file.txt ~\033[m (and then it awaits your content paste ending in an ~ line)"
  exit 1
# else if there are arguments
else
  # if there's only one argument
  if [ $# -eq 1 ]; then
    # if the only argument is a path ending in a file
    # (if the argument ends in a period followed by one or more characters)
    if [[ $1 =~ \..+$ ]]; then
      # create the directory/directories and then create the file 
      DIR=$(dirname $1)
      mkdir -p $DIR
      FILEPATH=$1
      touch $FILEPATH
    # if the only argument is just a directory or nested directory path with no file
    else
      # just create the directory/directories
      mkdir -p $1
    fi
  # if there's more than one argument and the second argument is just a tilda
  elif [ $2 == ~ ]; then
    # create the directory/directories and the file
    DIR=$(dirname $1)
    mkdir -p $DIR
    FILEPATH=$1
    touch $FILEPATH
    TEXT=$(sed '/^~$/q')            # and then wait for pasted input ending in a line with just ~ (and then wait for the enter key)
    echo "$TEXT" > $FILEPATH        # print the input to the file
    sed -i '' -e '$ d' $FILEPATH    # delete the last line of the file (the ~ line)
  # if there's more than one argument and the second argument is not just a tilda
  else
    DIR=$1
    mkdir -p $DIR             # create the directory/directories
    shift                     # remove the first argument from the array of all the arguments
    for FILE in "$@"          # loop through the remaining arguments array
    do
      FILEPATH="$DIR/$FILE"
      touch $FILEPATH         # create each file in the arguments array
    done    
  fi
fi