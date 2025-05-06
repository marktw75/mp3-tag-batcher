#!/bin/bash

echo "| 檔名 | 標題 | 藝人 | 專輯 | 曲目 |"
echo "|------|------|------|------|------|"

for file in *.mp3; do
  info=$(eyeD3 --no-color "$file")

  title=$(echo "$info" | grep "title:" | sed 's/^.*title: //')
  artist=$(echo "$info" | grep "artist:" | sed 's/^.*artist: //')
  album=$(echo "$info" | grep "album:" | sed 's/^.*album: //')
  track=$(echo "$info" | grep "track:" | sed 's/^.*track: //')

  echo "| $file | $title | $artist | $album | $track |"
done
