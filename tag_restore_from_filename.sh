#!/bin/bash

# Usage:
# ./tag_restore_from_filename_v2.sh --artist "草蜢" --album "草蜢30週年紀念珍藏A" --year 2025

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --artist) artist="$2"; shift ;;
    --album) album="$2"; shift ;;
    --year) year="$2"; shift ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

if [[ -z "$artist" || -z "$album" || -z "$year" ]]; then
  echo "❌ 請輸入 --artist, --album, --year"
  exit 1
fi

if ! command -v eyeD3 &>/dev/null; then
  echo "❌ 請先安裝 eyeD3：sudo apt install eyed3"
  exit 1
fi

echo "🎵 使用者資訊："
echo "Artist: $artist"
echo "Album : $album"
echo "Year  : $year"
echo

echo "📝 產生 tracklist.md ..."
> tracklist.md

first_mp3=""

for file in *.mp3; do
  base=$(basename "$file" .mp3)
  track="${base%% *}"
  title="${base#* }"

  # 存到 tracklist.md
  echo "$index. $title" >> tracklist.md
  index=$((index + 1))

  # 寫 metadata
  eyeD3 --encoding utf16 --to-v2.3 --force-update \
        --title "$title" \
        --artist "$artist" \
        --album "$album" \
        --recording-date "$year" \
        --track "$track" \
        "$file"

  echo "✅ 已更新：$file"

  # 記下第一個檔名用來提取封面
  if [[ -z "$first_mp3" ]]; then
    first_mp3="$file"
  fi
done

echo
if [[ -f cover.jpg ]]; then
  echo "🖼️ 已有 cover.jpg，略過擷取封面"
else
  echo "🖼️ 嘗試從 $first_mp3 擷取封面..."
  mkdir -p _cover_extract
  cd _cover_extract
  eyeD3 --write-images=. "../$first_mp3" &>/dev/null
  if [[ -f FRONT_COVER.jpg ]]; then
    mv FRONT_COVER.jpg ../cover.jpg
    echo "✅ 成功產生 cover.jpg"
  else
    echo "⚠️ 無法從 MP3 中找到封面圖"
  fi
  cd ..
  rm -rf _cover_extract
fi

echo
echo "📄 已產出 tracklist.md，🎨 嘗試擷取封面完成"
echo "🎉 所有 metadata 補寫完成！"