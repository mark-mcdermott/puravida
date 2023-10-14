# Puravida

## Overview
`puravida` is a tiny bash script that creates a terminal command that's a simple one-liner replacement for `mkdir` and `touch` and it's also a cleaner replacement for multi-line text insertion like `cat >> file.txt << 'END'` (i.e., [here documents](https://en.wikipedia.org/wiki/Here_document)). I made  `puravida` because I used these all the time and it just annoyed me that this didn't already exist. Now I use `puravida` all the time.

## More Detail
Once `puravida` is in your system path, instead of two commands like `mkdir folder` and `echo "hi" >> folder/file.txt` (which of course can be combined in a one-liner like `mkdir folder && echo "hi" >> folder/file.txt`), you can do a clean one-liner with `puravida` like this: 
```
puravida folder/file.txt "hi"
```
`puravida` can also be a cleaner workaround for putting multiline text in a file in a folder which doesn't exist yet. Instead of
```
mkdir folder
cat >> file.txt << 'END'
first text line
second text line
END
```
you can instead use `puravida` like this:
```
puravida folder/file.txt ~
first text line
second text line
~
```
To take all this to its logical conclusion, you can use puravida instead of `touch` to create an empty file. Instead of `touch file.txt` you can do `puravida file.txt`. Same with `mkdir` - instead of creating just an empty folder with `mkdir folder` you can do `puravida folder`.

`mkdir && touch`, `cat >> file.txt << 'END'` - just whyyyyy. Just use `puravida` and enjoy your life a little more 🌴

## Setup
- In mac/linux drop this file in `/usr/bin/local` (in mac finder hit `cmd + shift + .` if you don't see the hidden usr folder).
- Run `sudo chmod 755 puravida` to give it the right permissions.
- Now you should be able to use this anywhere .
- Note: this is macOS specific because of the sed command - you can tweak it on linux. something like `sed -i '$ d' $FILEPATH` might work (untested)

## Main Use Cases
🌴 usage 1: oneliner combining `mkdir -p` and `touch`. e.g., `puravida dir_1/dir_2/file.txt`

🌊 usage 2: create (optionally nested) directory and multiple files in it. e.g., `puravida dir/nested_dir file1.txt file2.txt`

🏖️ usage 3: create (optionally nested) directory a file in it with (optionally multiline) contents (last line must just say ~ and that's all) you paste in and hit enter.
e.g., `puravida dir/file.txt ~` (and then it awaits your content paste ending in an `~` line)

by mark mcdermott 7/6/23, https://markmcdermott.io
open sourced under MIT license# puravida
