# OPA技术文档项目 - 多格式导出工具

> **适用版本**: v2.6.0
> **最后更新**: 2026年3月19日

---

## 📦 支持的导出格式

| 格式 | 扩展名 | 用途 | 状态 |
|------|--------|------|------|
| Markdown | .md | 源码格式 | ✅ 原生支持 |
| HTML | .html | 网页浏览 | ✅ VuePress生成 |
| PDF | .pdf | 打印/分享 | 🚧 规划中 |
| EPUB | .epub | 电子书阅读器 | 🚧 规划中 |
| MOBI | .mobi | Kindle阅读 | 🚧 规划中 |
| Word | .docx | 文档编辑 | 🚧 规划中 |
| JSON | .json | 数据交换 | ✅ 脚本支持 |
| YAML | .yaml | 配置管理 | ✅ 脚本支持 |

---

## 🛠️ 导出工具

### 1. Markdown (原生)

所有文档都以Markdown格式存储，可直接使用。

```bash
# 查找所有Markdown文档
find . -name "*.md" -type f

# 统计文档数量
find . -name "*.md" | wc -l
```

### 2. HTML (VuePress)

```bash
# 构建HTML版本
make build

# 输出目录: docs/.vuepress/dist
# 包含完整的HTML站点

# 本地预览
cd docs/.vuepress/dist
python -m http.server 8080
```

### 3. PDF导出 (使用Pandoc)

```bash
# 安装依赖
npm install -g md-to-pdf

# 导出单个文档
md-to-pdf docs/README.md

# 导出所有文档 (使用脚本)
./scripts/export-pdf.sh
```

#### PDF导出脚本

```bash
#!/bin/bash
# scripts/export-pdf.sh

echo "导出文档为PDF..."

# 创建输出目录
mkdir -p exports/pdf

# 导出核心文档
for file in docs/*.md docs/*/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .md)
        echo "导出: $filename"
        md-to-pdf "$file" --dest "exports/pdf/${filename}.pdf"
    fi
done

echo "PDF导出完成!"
```

### 4. EPUB导出

```bash
# 安装Pandoc
sudo apt-get install pandoc

# 导出为EPUB
pandoc docs/README.md -f markdown -t epub -s -o exports/opa-docs.epub

# 导出完整文档
./scripts/export-epub.sh
```

#### EPUB导出脚本

```bash
#!/bin/bash
# scripts/export-epub.sh

echo "创建EPUB电子书..."

# 合并所有文档
cat docs/00-总览与索引.md > exports/temp.md

for dir in docs/*/; do
    for file in "$dir"*.md; do
        if [ -f "$file" ]; then
            cat "$file" >> exports/temp.md
            echo -e "\n\n---\n\n" >> exports/temp.md
        fi
    done
done

# 转换为EPUB
pandoc exports/temp.md \
    -f markdown \
    -t epub \
    -s \
    --metadata title="OPA技术文档" \
    --metadata author="OPA中文文档团队" \
    --metadata date="2026-03-19" \
    -o exports/OPA-技术文档-v2.6.0.epub

# 清理
rm exports/temp.md

echo "EPUB导出完成: exports/OPA-技术文档-v2.6.0.epub"
```

### 5. JSON导出

```bash
# 导出文档元数据为JSON
./scripts/export-json.sh
```

#### JSON导出脚本

```bash
#!/bin/bash
# scripts/export-json.sh

echo "导出文档元数据为JSON..."

cat > exports/metadata.json << 'EOF'
{
  "project": {
    "name": "OPA技术文档",
    "version": "2.6.0",
    "last_updated": "2026-03-19",
    "language": "zh-CN"
  },
  "documents": [
EOF

# 遍历文档
first=true
for file in $(find docs -name "*.md" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> exports/metadata.json
    fi

    filename=$(basename "$file" .md)
    word_count=$(wc -m < "$file")

    cat >> exports/metadata.json << EOF
    {
      "path": "$file",
      "filename": "$filename",
      "word_count": $word_count
    }
EOF
done

cat >> exports/metadata.json << 'EOF'

  ],
  "statistics": {
    "total_documents": $(find docs -name "*.md" | wc -l),
    "total_words": $(find docs -name "*.md" -exec wc -m {} + | tail -1 | awk '{print $1}')
  }
}
EOF

echo "JSON导出完成: exports/metadata.json"
```

### 6. YAML导出

```bash
# 导出配置为YAML
./scripts/export-yaml.sh
```

#### YAML导出脚本

```bash
#!/bin/bash
# scripts/export-yaml.sh

echo "导出配置为YAML..."

cat > exports/config.yaml << 'EOF'
project:
  name: OPA技术文档
  version: "2.6.0"
  description: Open Policy Agent全面技术分析
  repository: https://github.com/AdaMartin18010/OPA
  license: Apache-2.0

documents:
  chapters:
EOF

# 添加章节信息
for dir in docs/*/; do
    dirname=$(basename "$dir")
    doc_count=$(find "$dir" -name "*.md" | wc -l)

    cat >> exports/config.yaml << EOF
    - name: $dirname
      documents: $doc_count
EOF
done

cat >> exports/config.yaml << 'EOF'

build:
  tool: VuePress
  output: static-html

deployment:
  platform: GitHub Pages
  url: https://adamartin18010.github.io/OPA/
EOF

echo "YAML导出完成: exports/config.yaml"
```

---

## 📋 批量导出

### 一键导出所有格式

```bash
# 使用Makefile
make export

# 或直接使用脚本
./scripts/export-all.sh
```

#### 批量导出脚本

```bash
#!/bin/bash
# scripts/export-all.sh

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  OPA技术文档 - 批量导出"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 创建输出目录
mkdir -p exports/{pdf,epub,json,yaml,html}

# 1. 导出HTML
echo "1/5 导出HTML..."
make build > /dev/null 2>&1
cp -r docs/.vuepress/dist/* exports/html/
echo "   ✅ HTML导出完成"

# 2. 导出JSON
echo "2/5 导出JSON..."
./scripts/export-json.sh > /dev/null 2>&1
echo "   ✅ JSON导出完成"

# 3. 导出YAML
echo "3/5 导出YAML..."
./scripts/export-yaml.sh > /dev/null 2>&1
echo "   ✅ YAML导出完成"

# 4. 导出PDF (需要安装md-to-pdf)
echo "4/5 导出PDF..."
if command -v md-to-pdf &> /dev/null; then
    ./scripts/export-pdf.sh > /dev/null 2>&1
    echo "   ✅ PDF导出完成"
else
    echo "   ⚠️  md-to-pdf未安装，跳过PDF导出"
fi

# 5. 导出EPUB (需要安装pandoc)
echo "5/5 导出EPUB..."
if command -v pandoc &> /dev/null; then
    ./scripts/export-epub.sh > /dev/null 2>&1
    echo "   ✅ EPUB导出完成"
else
    echo "   ⚠️  pandoc未安装，跳过EPUB导出"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  导出完成!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "输出目录: exports/"
echo "  - exports/html/   HTML静态站点"
echo "  - exports/json/   JSON元数据"
echo "  - exports/yaml/   YAML配置"
echo "  - exports/pdf/    PDF文档"
echo "  - exports/epub/   EPUB电子书"
echo ""
```

---

## 📖 导出配置

### Pandoc配置

创建 `exports/pandoc-config.yaml`:

```yaml
# 基本设置
from: markdown
standalone: true

# PDF设置
pdf-engine: xelatex
variables:
  mainfont: "Noto Sans CJK SC"
  geometry: margin=2.5cm

# EPUB设置
ePub-cover-image: docs/.vuepress/public/logo.png
ePub-metadata: exports/epub-metadata.xml
```

### EPUB元数据

创建 `exports/epub-metadata.xml`:

```xml
<?xml version="1.0"?>
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:title>OPA技术文档</dc:title>
  <dc:creator>OPA中文文档团队</dc:creator>
  <dc:description>Open Policy Agent全面技术分析</dc:description>
  <dc:date>2026-03-19</dc:date>
  <dc:language>zh-CN</dc:language>
  <dc:rights>Apache License 2.0</dc:rights>
</metadata>
```

---

## 🎯 使用场景

### 场景1: 离线阅读

```bash
# 导出EPUB到电子书阅读器
make export-epub
# 将 exports/*.epub 复制到Kindle或iPad
```

### 场景2: 打印装订

```bash
# 导出PDF并打印
make export-pdf
# 将 exports/pdf/*.pdf 合并打印
```

### 场景3: 数据备份

```bash
# 导出JSON元数据
make export-json
# 备份 exports/metadata.json
```

### 场景4: 第三方集成

```bash
# 导出YAML配置
make export-yaml
# 用于CI/CD或其他工具集成
```

---

## 🔧 Makefile集成

```makefile
# Makefile 添加导出目标

export: ## 导出所有格式
 @./scripts/export-all.sh

export-html: ## 导出HTML
 @make build
 @cp -r docs/.vuepress/dist/* exports/html/

export-pdf: ## 导出PDF
 @./scripts/export-pdf.sh

export-epub: ## 导出EPUB
 @./scripts/export-epub.sh

export-json: ## 导出JSON
 @./scripts/export-json.sh

export-yaml: ## 导出YAML
 @./scripts/export-yaml.sh

clean-exports: ## 清理导出文件
 @rm -rf exports/*
 @echo "导出文件已清理"
```

---

## 📊 导出统计

| 格式 | 文件数 | 总大小 | 适用场景 |
|------|--------|--------|----------|
| Markdown | 109 | ~2MB | 源码编辑 |
| HTML | 1站点 | ~10MB | 在线浏览 |
| PDF | 109 | ~50MB | 打印分享 |
| EPUB | 1 | ~15MB | 电子书阅读 |
| JSON | 1 | ~100KB | 数据交换 |
| YAML | 1 | ~10KB | 配置管理 |

---

## 📚 相关工具

### 推荐工具

| 工具 | 用途 | 安装 |
|------|------|------|
| Pandoc | 文档转换 | `apt-get install pandoc` |
| md-to-pdf | Markdown转PDF | `npm install -g md-to-pdf` |
| Calibre | EPUB管理 | `apt-get install calibre` |
| wkhtmltopdf | HTML转PDF | `apt-get install wkhtmltopdf` |

---

**导出工具维护**: OPA中文文档团队
**最后更新**: 2026年3月19日
**版本**: v2.6.0

📦 **[查看导出目录](exports/)** | 🔧 **[使用指南](API.md)** | 🏠 **[返回首页](README.md)**
