# puravida demo — render with:  vhs demo.tape
# Produces demo.gif at the repo root. Runs in a throwaway temp dir using the
# repo's own 2.0 script, so it neither litters the repo nor depends on PATH.

Output "/Users/stuxxnet/Dev/puravida/demo.gif"

Set Shell "bash"
Set FontSize 18
Set Width 1040
Set Height 680
Set Padding 22
Set Theme "Catppuccin Mocha"
Set TypingSpeed 45ms

# --- hidden setup -----------------------------------------------------------
Hide
Type "export PATH=/Users/stuxxnet/Dev/puravida:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" Enter
Type "cd $(mktemp -d)" Enter
Type `export PS1='🌴 \[\e[38;5;42m\]puravida\[\e[0m\] \[\e[38;5;75m\]❯\[\e[0m\] '` Enter
Type "clear" Enter
Show

Sleep 600ms

# 1) one command instead of `mkdir -p && touch`
Type "# one command, not two — parents are made for you" Enter
Type "puravida src/components/Button.tsx" Sleep 300ms Enter
Sleep 700ms
Enter

# 2) many paths at once: dotted leaf = file, plain leaf = directory
Type "# many paths at once: a dot makes a file, no dot makes a dir" Enter
Type "puravida a.txt b.txt assets/" Sleep 300ms Enter
Sleep 700ms
Enter

# 3) a leading directory holds everything named after it (with nesting)
Type "# a leading directory holds the paths after it" Enter
Type "puravida .config/ settings.json themes/dark.css" Sleep 300ms Enter
Sleep 600ms
Type "tree -a" Enter
Sleep 2000ms
Enter

# 4) inline content after the ~~ marker
Type "# inline content goes after ~~" Enter
Type "puravida hello.txt ~~ hello, world" Sleep 300ms Enter
Type "cat hello.txt" Enter
Sleep 1300ms
Enter

# 5) single-quote to keep quotes and semicolons literal
Type "# single-quote anything with quotes, $ or ;" Enter
Type `puravida app.css ~~ '@import "tailwindcss";'` Sleep 300ms Enter
Type "cat app.css" Enter
Sleep 1600ms
Enter

# 6) -f forces dotless names to be files
Type "# -f forces dotless names (Makefile, LICENSE) to be files" Enter
Type "puravida -f Makefile LICENSE" Sleep 300ms Enter
Type "ls" Enter
Sleep 1400ms
Enter

# 7) a bare ~ pastes multi-line content, ending on a lone ~
Type "# a bare ~ pastes multi-line content; end with a lone ~" Enter
Type "puravida haiku.txt ~" Enter
Sleep 400ms
Type "code flows like water" Enter
Type "folders bloom across the disk" Enter
Type "pura vida, friend" Enter
Type "~" Enter
Sleep 500ms
Type "cat haiku.txt" Enter
Sleep 2600ms
