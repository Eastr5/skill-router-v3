# Skill Router v3 🧭

[![Skills](https://img.shields.io/badge/skills-30%2B-blue)](https://github.com/your-username/skill-router-v3)
[![Platforms](https://img.shields.io/badge/platforms-Trae%20%7C%20Claude%20%7C%20Cursor%20%7C%20VSCode-green)](https://github.com/your-username/skill-router-v3)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)
[![MST](https://img.shields.io/badge/architecture-MCP--Skill--Tool-orange)](docs/architecture.md)

> **首个 MCP-Skill-Tool (MST) 三层统一路由引擎** — 让 AI 自动决定用什么工具、什么 Skill、什么 MCP。

## ✨ 30 秒看懂

```
用户: "画个 Transformer 架构图放我论文里"
     ↓
AI:  🧠 意图分析 → 科研插图 + LaTeX/TikZ + 出版级 (置信度 0.95)
     ↓
AI:  🎯 自动调用 tikz-diagrams-guide + figura
     ↓
AI:  ✅ 生成 .tex → 编译 PDF → 展示 PNG
```

**不用记几十个 Skill 的名字，不用纠结该用哪个工具。说出来，AI 自动路由。**

## 🚀 一键安装

### Trae
```bash
curl -sSL https://raw.githubusercontent.com/your-username/skill-router-v3/main/install.sh | bash
```

### Claude Code
```bash
mkdir -p ~/.claude/skills/skill-router
curl -sSL https://raw.githubusercontent.com/your-username/skill-router-v3/main/skills/skill-router/SKILL.md \
  -o ~/.claude/skills/skill-router/SKILL.md
```

### Cursor / VSCode
见 [跨平台迁移指南](docs/platform-guide.md)

## 🏗️ MST 三层架构

```
┌─────────────────────────────────────────┐
│  USER REQUEST                           │
│  ↓                                      │
│  INTENT ANALYSIS                        │
│  ├── Task type / Complexity / Urgency   │
│  └── Constraints                        │
│  ↓                                      │
│  CAPABILITY MATCHING                    │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ MCP     │ │ Skill   │ │ Tool    │   │
│  │ Layer   │ │ Layer   │ │ Layer   │   │
│  │ 外部服务 │ │ 领域知识 │ │ 原生操作 │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│  ↓                                      │
│  EXECUTION DECISION                     │
│  ├── Confidence ≥ 0.9 → Auto-invoke     │
│  ├── Confidence 0.7-0.9 → Recommend     │
│  └── Confidence < 0.7 → Interview       │
└─────────────────────────────────────────┘
```

| 层级 | 职责 | 示例 |
|---|---|---|
| **MCP** | 外部服务连接 | 论文搜索、数据库、GitHub、Draw.io |
| **Skill** | 领域知识注入 | TikZ 绘图、代码审查、数据分析 |
| **Tool** | 原生 IDE 操作 | 读写文件、执行命令、搜索代码 |

## 🎯 三种执行模式

### Mode A: Auto-Invoke (置信度 ≥ 0.9)
意图明确，直接执行，不问废话。

```
用户: "画个 Transformer 架构图放我论文里"
→ 自动调用: tikz-diagrams-guide + figura
```

### Mode B: Recommend + Confirm (置信度 0.7-0.9)
意图较明确，但选择有讲究，给建议让用户确认。

```
用户: "我想可视化一些数据"
→ 建议: "用 figura (matplotlib, 适合论文) 还是 chart-visualization (JS, 适合网页)?"
```

### Mode C: Interview (置信度 < 0.7)
意图模糊，先问清楚再行动。

```
用户: "帮我做个东西"
→ 询问: "1) 网站/应用 2) 数据分析 3) 论文/研究 4) 设计/图?"
```

## 📊 与竞品的对比

| 特性 | [lingxling](https://github.com/lingxling/awesome-skills-cn) (38⭐) | [TerminalSkills](https://github.com/TerminalSkills/skills) (26⭐) | **Skill Router v3** |
|---|---|---|---|
| **MCP 感知** | ❌ 无 | ❌ 无 | ✅ **健康检查 + Fallback** |
| **半决策化** | ❌ 总是询问 | ❌ 手动配置 | ✅ **置信度阈值自动决策** |
| **跨平台** | ❌ Antigravity 专用 | ❌ Claude Code 专用 | ✅ **Trae/Claude/Cursor/VSCode** |
| **环境感知** | ❌ 无 | ❌ 无 | ✅ **YAML 注册表 + 状态检测** |
| **三层架构** | ❌ 仅 Skill | ❌ 仅 Agent | ✅ **MCP + Skill + Tool** |
| **组合配方** | 少量 | 无 | ✅ **12 个 MST 组合** |
| **中文支持** | ✅ | ❌ | ✅ **"我该用啥" 触发** |

## 🧩 12 个 MST 组合配方

| # | 场景 | MCP | Skill | Tool |
|---|---|---|---|---|
| 1 | 找论文+读+整理 | `paper-search` → `semantic-scholar` | `literature-search` → `academic-research-assistant` | `Read` |
| 2 | 画科研图+编译 | — | `tikz-diagrams-guide` → `figura` | `RunCommand` (pdflatex) |
| 3 | Excel数据→报告 | `MySQL` (如有) | `data-analysis` → `consulting-analysis` | `Read` |
| 4 | Figma→React代码 | — | `figma` → `frontend-design` → `shadcn` | `Write` |
| 5 | 代码审查+安全 | — | `TRAE-code-review` + `TRAE-security-review` | `Read` |
| 6 | 网页→笔记 | — | `defuddle` → `obsidian-markdown` | `WebFetch` |
| 7 | 系统综述PRISMA | `paper-search` | `literature-search` → `academic-research-assistant` | `Task` |
| 8 | Web app QA | — | `dogfood` + `agent-browser` | `RunCommand` |
| 9 | 搭SaaS落地页 | — | `web-dev` → `frontend-design` → `theme-factory` | `RunCommand` |
| 10 | 视频分析报告 | — | `hook-analyzer` → `report-generator` | `Read` |
| 11 | 多模型代码生成 | `AI router MCP` | `agent-swarm-orchestration` | `Task` |
| 12 | 论文端到端发表 | `paper-search` + `semantic-scholar` | `literature-search` → `academic-research-assistant` → `figura` | `RunCommand` |

## 🌐 跨平台兼容

| 平台 | Skill 路径 | 状态 |
|---|---|---|
| **Trae** | `~/.trae-cn/builtin/global/skills/` + `<project>/.trae/skills/` | ✅ 原生支持 |
| **Claude Code** | `~/.claude/skills/` | ✅ 已验证 |
| **Cursor** | `.cursor/skills/` | 🧪 实验性 |
| **VSCode + Cline** | `.cline/skills/` | 🧪 实验性 |

> 迁移只需复制 `SKILL.md` 文件并更新路径。详见 [跨平台迁移指南](docs/platform-guide.md)。

## 📦 包含的 Skills

### 核心路由
- **`skill-router`** — MST 统一编排器（本仓库）

### 科研学术
- **`figura`** — 出版级图表（matplotlib + TikZ）
- **`tikz-diagrams-guide`** — TikZ 模板（Transformer/3D/贝叶斯/交换图）

## 🛠️ 快速开始

### 1. 安装
```bash
curl -sSL https://raw.githubusercontent.com/your-username/skill-router-v3/main/install.sh | bash
```

### 2. 重启你的 AI IDE
Trae / Claude Code / Cursor 需要重启才能加载新 Skill。

### 3. 使用
直接说出你的需求，AI 会自动路由：

```
用户: 我该用啥 skill 找论文？
AI:  🧭 推荐 literature-search（多数据库文献搜索）
     配套: mcp_paper-search + mcp_semantic-scholar
```

或者让 AI 自动决策：
```
用户: 画个贝叶斯网络放我 paper 里
AI:  ✅ 自动调用 tikz-diagrams-guide + figura
```

## 📁 仓库结构

```
skill-router-v3/
├── README.md                 # 本文件
├── LICENSE                   # MIT
├── install.sh                # 一键安装脚本
├── skills/
│   ├── skill-router/         # MST 统一路由引擎
│   ├── figura/               # 出版级图表
│   └── tikz-diagrams-guide/  # TikZ 科研绘图
├── examples/                 # 场景示例
├── docs/                     # 文档
│   ├── architecture.md       # MST 架构详解
│   └── platform-guide.md     # 跨平台迁移
└── assets/                   # 演示资源
```

## 🤝 贡献

欢迎提交 PR！特别是：
- 新的 Skill 路由规则
- 更多平台适配
- 实际使用案例

详见 [贡献指南](docs/contributing.md)。

## 📄 License

MIT © 2026

---

> **Star ⭐ 这个仓库**，如果你也觉得 AI 应该自己决定用什么工具。
