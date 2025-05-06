# 🎵 mp3-tag-batcher

A simple shell script to batch list ID3 tag info (Title, Artist, Album, Track) from `.mp3` files in the current folder.

Outputs the result as a **Markdown table**, perfect for GitHub README, HackMD, or documentation.

---

## 📦 Features

- Batch extract Title / Artist / Album / Track info
- Unicode-safe (supports Chinese, Japanese, etc.)
- Output in Markdown format
- Light and dependency-free (only needs `eyeD3`)

---

## 🚀 Usage

### Install dependencies (Ubuntu / Debian):
```bash
sudo apt install eyed3
```

### Run the script:
```bash
chmod +x list_mp3_tags.sh
./list_mp3_tags.sh
```

---

## 📝 Sample Output

| Filename | Title | Artist | Album | Track |
|----------|-------|--------|-------|-------|
| 01 滿身火燙的女人.mp3 | 滿身火燙的女人 | 草蜢 | 草蜢30週年紀念珍藏A | 1 |

---

## 📁 Files

- `list_mp3_tags.sh` — the shell script
- `example-output.md` — sample output table

---

## 🪪 License

MIT
