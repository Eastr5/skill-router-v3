---
name: "skill-router-lite"
description: "Lightweight skill router for quick decision-making. Pure decision tree, no MCP/Tool management. Invoke when you just need to know 'which skill should I use' without complex orchestration."
---

# Skill Router Lite — 轻量决策树

> **Fast. Simple. No dependencies.** Just tell you which skill to use.

## Decision Tree (depth ≤ 3)

```
USER REQUEST
│
├─ 学术研究 / 论文
│  ├─ 找论文 / 下载 / 引用
│  │   → literature-search
│  ├─ 读论文 / 做笔记 / 研究方向
│  │   → academic-research-assistant
│  ├─ 画科研图（架构/流程/交换图）
│  │   → tikz-diagrams-guide
│  └─ 修图 / 美化 / 出版级
│      → figura
│
├─ 前端 / Web
│  ├─ 从零搭网站
│  │   → web-dev
│  ├─ 设计 landing / React
│  │   → frontend-design
│  ├─ Figma 设计稿 → 代码
│  │   → figma
│  └─ UI 组件 / shadcn
│      → shadcn
│
├─ 设计 / 视觉
│  ├─ 海报 / 艺术作品
│  │   → canvas-design
│  ├─ 算法艺术 / p5.js
│  │   → algorithmic-art
│  └─ 统计图表
│      → chart-visualization
│
├─ 文档 / 报告
│  ├─ 技术提案 / 规格
│  │   → doc-coauthoring
│  ├─ 市场分析 / 投资
│  │   → consulting-analysis
│  └─ 网页 → Markdown
│      → defuddle
│
├─ 数据 / 分析
│  ├─ Excel / CSV 处理
│  │   → data-analysis
│  └─ 浏览器自动化
│      → agent-browser
│
├─ 代码
│  ├─ 代码审查
│  │   → TRAE-code-review
│  └─ 安全扫描
│      → TRAE-security-review
│
├─ Obsidian 笔记
│  ├─ 笔记管理
│  │   → obsidian-cli
│  └─ Markdown 格式
│      → obsidian-markdown
│
└─ 不知道 / 模糊
    └─ 问用户 1-2 个问题
```

## Output Format

```markdown
## 🧭 Skill 建议

**推荐**: `<skill-name>` — <一句话说明>
**理由**: <为什么选这个>
**下一步**: <直接操作>
```

## 5 秒规则

- 如果能在 5 秒内确定 skill → 直接回答
- 如果不能 → 问 1 个澄清问题
- 绝不推荐超过 2 个 skill

## Constraints
- NO MCP management
- NO Tool layer orchestration
- NO confidence scoring
- NO cross-platform detection
- Just pure skill → task matching
