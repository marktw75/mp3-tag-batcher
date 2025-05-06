#!/bin/bash

tracklist_file="tracklist.txt"
artist="草蜢"
album="草蜢30週年紀念珍藏B"
year="2020"
cover_image="cover.jpg"
dry_run=false
do_backup=false

# 解析參數
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --backup)  do_backup=true ;;
  esac
done

# 檢查工具與檔案
if ! command -v eyeD3 &>/dev/null; then
  echo "❌ 請先安裝 eyeD3：sudo apt install eyed3"
  exit 1
fi

if [ ! -f "$cover_image" ]; then
  echo "❌ 找不到封面圖檔案 $cover_image"
  exit 1
fi

if [ ! -f "$tracklist_file" ]; then
  echo "❌ 找不到曲目清單檔案 $tracklist_file"
  exit 1
fi

# 找 MP3 檔案
mapfile -t mp3_files < <(ls *.mp3 | sort)
if [ ${#mp3_files[@]} -eq 0 ]; then
  echo "❌ 沒有找到 mp3 檔案"
  exit 1
fi

# 讀取曲目清單
mapfile -t title_lines < "$tracklist_file"

# 檢查格式正確
bad_lines=()
for i in "${!title_lines[@]}"; do
  if [[ ! "${title_lines[$i]}" =~ ^[0-9]{2}[[:space:]]+.+$ ]]; then
    bad_lines+=("$((i + 1))：${title_lines[$i]}")
  fi
done

if [ ${#bad_lines[@]} -gt 0 ]; then
  echo "❌ 發現 ${#bad_lines[@]} 筆格式錯誤："
  printf '  ⚠️  第 %s\n' "${bad_lines[@]}"
  echo "請確認每行格式為：01 歌名"
  exit 1
fi

# 數量一致性
if [ ${#mp3_files[@]} -ne ${#title_lines[@]} ]; then
  echo "❌ MP3 數量（${#mp3_files[@]}）與曲目清單（${#title_lines[@]}）不一致！"
  exit 1
fi

# 預覽
echo "🔎 將進行以下變更（預覽）:"
for ((i = 0; i < ${#title_lines[@]}; i++)); do
  raw="${title_lines[$i]}"
  track_num=$(printf "%02d" $((i + 1)))
  title="${raw#* }"
  file="${mp3_files[$i]}"
  new_name="$track_num $title.mp3"

  echo "🎵 $file → $new_name"
  echo "    ↪ Title: $title"
  echo "    ↪ Track #: $((i + 1))"
done

if $dry_run; then
  echo
  echo "🧪 Dry run 模式啟用，不會進行任何變更。"
  if $do_backup; then
    echo "💾 但仍會備份 MP3 至 backup/（僅複製，不改檔名）"
    mkdir -p backup
    for file in "${mp3_files[@]}"; do
      cp -f -- "$file" "backup/$file"
    done
    echo "✅ 備份完成！"
  fi
  exit 0
fi

echo
read -p "✅ 是否繼續執行這些變更？[y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "🚫 使用者取消操作。"
  exit 0
fi

# 備份階段
if $do_backup; then
  echo "💾 備份中..."
  mkdir -p backup
  for file in "${mp3_files[@]}"; do
    cp -f -- "$file" "backup/$file"
  done
  echo "✅ 備份完成！"
fi

# 執行改名 + 寫入 tag
echo "🚀 開始處理..."
for ((i = 0; i < ${#title_lines[@]}; i++)); do
  raw="${title_lines[$i]}"
  track_num=$(printf "%02d" $((i + 1)))
  title="${raw#* }"
  file="${mp3_files[$i]}"
  new_name="$track_num $title.mp3"

  mv -i -- "$file" "$new_name"

  eyeD3 --encoding utf16 --to-v2.3 --force-update \
        --title "$title" \
        --artist "$artist" \
        --album "$album" \
        --recording-date "$year" \
        --track "$((i + 1))" \
        --add-image "$cover_image:FRONT_COVER" \
        "$new_name"

  echo "✅ 已處理: $new_name"
done

echo "🎉 全部完成！"

