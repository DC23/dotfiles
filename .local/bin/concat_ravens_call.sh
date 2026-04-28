#!/usr/bin/env bash

PROJECT_ROOT="/mnt/c/Users/juggl/OneDrive/Documents/Obsidian/RPG/Campaigns/Ravens Call"

concat_characters.py \
  --lifepaths "${PROJECT_ROOT}/Lifepaths" \
  --profiles "${PROJECT_ROOT}/Character Profiles/PCs" \
  --voices "${PROJECT_ROOT}/Character Profiles/Voice Documents/Platonic" \
  --output "${PROJECT_ROOT}/Character References" \
  --characters "Monarch,Fixer,Failsafe,Vertigo,Ash"
