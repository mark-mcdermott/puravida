#!/bin/bash
# Copyright 2023 Mark McDermott
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# tests for puravida mkdir/touch one-liner (available at https://gist.github.com/mark-mcdermott/f08fdedbd7b3c2f0dc3adda76e47815a)

main() {
  echo ""
  safety_check
  test1
  test2
  test3
  test4
  test5
  test6
  test7
  echo ""
}

test1() {
  TEST="single dir creation"
  puravida dir1
  if 
    [ -d "dir1" ]; 
  then 
  success; else failure; fi; echo " $TEST";
  rm -rf dir1
}

test2() {
  TEST="single dir creation with file"
  puravida dir1/test.txt
  if 
    [ -d "dir1" ] && [ -f "dir1/test.txt" ]; 
  then
  success; else failure; fi; echo " $TEST";
  rm -rf dir1
}

test3() {
  TEST="two dir creation"
  puravida dir1/dir2
  if 
    [ -d "dir1" ] && [ -d "dir1/dir2" ];
  then 
  success; else failure; fi; echo " $TEST";
  rm -rf dir1
}

test4() {
  TEST="two dir creation with file"
  puravida dir1/dir2/test.txt
  if 
    [ -d "dir1" ] && [ -d "dir1/dir2" ] && [ -f "dir1/dir2/test.txt" ];
  then 
  success; else failure; fi; echo " $TEST";
  rm -rf dir1
}

test5() {
  TEST="one dir creation with two files"
  puravida dir1 test1.txt test2.txt
  if 
    [ -d "dir1" ] && [ -f "dir1/test1.txt" ] && [ -f "dir1/test2.txt" ];
  then 
  success; else failure; fi; echo " $TEST";
  rm -rf dir1
}

test6() {
  TEST="two dir creation with two files"
  puravida dir1/dir2 test1.txt test2.txt
  if 
    [ -d "dir1" ] && [ -d "dir1/dir2" ] && [ -f "dir1/dir2/test1.txt" ] && [ -f "dir1/dir2/test2.txt" ];
  then 
  success; else failure; fi; echo " $TEST";
  rm -rf dir1
}

# for this test, paste this in by hand when the tests pause here (but remove the #s)
# a
# b
# ~
test7() {
  TEST="pasting in input to created file in created subdirectory"
  puravida dir1/dir2/test1.txt ~
  if grep -Ez "^a\nb$" "dir1/dir2/test1.txt"; 
  then
  success; else failure; fi; echo " $TEST";  
  rm -rf dir1
}

safety_check() {
  if [ -d "dir1" ]; then
    echo "❌ dir1 directory already exists - exiting"
    exit
  fi
}

success() {
  echo -n "✅"
}

failure() {
  echo -n "❌"
}

main