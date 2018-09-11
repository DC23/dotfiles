#!/bin/bash

cat ~/.Conky/notes.txt | sed 's/^/ \${color #ddddff}x  \$color /g'
