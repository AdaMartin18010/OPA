#!/bin/bash
# OPA技术文档项目 - 索引生成脚本
# 自动生成文档索引

OUTPUT_FILE="PROJECT_INDEX_v2.6.0.md"

cat > "${OUTPUT_FILE}" << 'EOF'
# OPA技术文档项目 - 完整索引 v2.6.0

> **版本**: v2.6.0  
> **更新日期**: 2026年3月19日  
> **文档总数**: 74篇  
> **总字数**: 370,000+  
> **OPA版本**: v1.4+  
> **Rego版本**: v1.0

---

## 📚 文档总览

EOF

# 统计文档数量
echo "正在生成索引..."

# 添加核心文档列表
echo "" >> "${OUTPUT_FILE}"
echo "### 核心文档 ($(find docs -name "*.md" | wc -l)篇)" >> "${OUTPUT_FILE}"
echo "" >> "${OUTPUT_FILE}"

for dir in docs/*/; do
    dir_name=$(basename "${dir}")
    count=$(find "${dir}" -name "*.md" | wc -l)
    echo "- ${dir_name}: ${count}篇" >> "${OUTPUT_FILE}"
done

# 添加示例列表
echo "" >> "${OUTPUT_FILE}"
echo "### 代码示例 ($(ls -d examples/*/ 2>/dev/null | wc -l)个)" >> "${OUTPUT_FILE}"
echo "" >> "${OUTPUT_FILE}"

for dir in examples/*/; do
    example_name=$(basename "${dir}")
    echo "- [${example_name}](${dir})" >> "${OUTPUT_FILE}"
done

echo ""
echo "索引已生成: ${OUTPUT_FILE}"
