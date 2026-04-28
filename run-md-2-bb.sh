#!/bin/bash

RAVENS_CALL="/mnt/c/Users/juggl/OneDrive/Documents/Obsidian/RPG/Campaigns/Ravens Call"
START=30
END=37
OFFSET=-3

cd "$RAVENS_CALL"

for SCENE in $(seq $START $END); do
    md_to_bbcode.py "Scenes/Scene $SCENE.md" --offset $OFFSET --output "published/scene_$SCENE.txt"
done