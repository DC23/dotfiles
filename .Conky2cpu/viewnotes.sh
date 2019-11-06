#!/bin/bash

cat ~/.Conky2cpu/notes.txt | sed 's/^/ \${color #ddddff}x  \$color /g'
