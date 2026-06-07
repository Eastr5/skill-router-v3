---
name: "skill-router"
description: "Universal router for MCP-Skill-Tool (MST) stack. Invoke when user asks 'which skill/tool/MCP should I use', '我该用啥', or when AI is uncertain which external capability to call. Works across Trae/Claude Code/Cursor/VSCode."
---

# Skill Router v3 — MST (MCP-Skill-Tool) Unified Orchestrator

> **Semi-autonomous decision engine.** Not a worker — analyzes intent, matches against capability registry, recommends execution path, and can auto-invoke when confidence > threshold.

## Architecture: Three-Layer Capability Stack

```
┌─────────────────────────────────────────────────────────────┐
│  USER REQUEST                                               │
│  ↓                                                          │
│  INTENT ANALYSIS (LLM reasoning)                            │
│  ├── Task type: code / research / design / data / doc       │
│  ├── Complexity: simple / medium / complex / multi-stage    │
│  ├── Urgency: quick answer / thorough / production-ready    │
│  └── Constraints: offline / cost-sensitive / security       │
│  ↓                                                          │
│  CAPABILITY MATCHING                                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  MCP Layer  │  │ Skill Layer │  │  Tool Layer │         │
│  │  (external  │  │  (prompt    │  │  (native    │         │
│  │   services) │  │   macros)   │  │   IDE ops)  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│  ↓                                                          │
│  EXECUTION DECISION                                         │
│  ├── Confidence ≥ 0.9 → Auto-invoke                         │
│  ├── Confidence 0.7-0.9 → Recommend + ask confirm           │
│  └── Confidence < 0.7 → Ask clarifying questions            │
└─────────────────────────────────────────────────────────────┘
```

## Layer 1: MCP (Model Context Protocol)

External services connected via MCP. **State-aware** — checks if MCP is alive before recommending.

| MCP | Capability | Status Check | Fallback |
|---|---|---|---|
| `mcp_paper-search_*` | 文献搜索 (arXiv/Semantic Scholar) | Try `search_papers` | `WebSearch` |
| `mcp_semantic-scholar_*` | 引用分析/作者追踪 | Try `get_paper` | 手动 Google Scholar |
| `mcp_MySQL_*` | SQL 查询/数据分析 | Try `get_schema_info` | `data-analysis` skill |
| `mcp_GitHub_*` | Repo/PR/Issue/Actions | Try `search_repositories` | `gh-cli` skill |
| `mcp_drawio-official_*` | Mermaid/CSV → 流程图 | Try `open_drawio_mermaid` | `tikz-diagrams-guide` |
| `mcp_latex-mcp-server_*` | LaTeX 编译/文献管理 | ⚠️ Placeholder on this machine | `RunCommand` + pdflatex |

> **⚠️ MCP Health Check**: Before recommending an MCP, verify it's not a placeholder. The `mcp_latex-mcp-server_*` on this machine runs `python -m http.server 8080` — DO NOT call.

## Layer 2: Skills (Prompt Macros)

Domain-specific instruction sets. **Auto-discovered** from `.trae/skills/` and `~/.trae-cn/builtin/global/skills/`.

### 🔬 Research / Academic
| Skill | Trigger | Companion |
|---|---|---|
| `literature-search` | "找论文" "下载 PDF" "引用分析" | `mcp_paper-search_*` + `mcp_semantic-scholar_*` |
| `academic-research-assistant` | "研究助手" "苏格拉底" "论文规划" | `literature-search` |
| `tikz-diagrams-guide` | "TikZ" "LaTeX diagram" "Transformer" | `figura` |
| `figura` | "出版级" "修图" "plot" "schematic" | `tikz-diagrams-guide` |

### 🎨 Design / Frontend
| Skill | Trigger | Companion |
|---|---|---|
| `frontend-design` | "landing page" "React" "dashboard" | `shadcn` + `theme-factory` |
| `frontend-skill` | "克制风格" "图像主导" | `canvas-design` |
| `web-dev` | "从零搭网站" "完整应用" | `frontend-design` |
| `figma` | "Figma 设计稿" "设计转代码" | `frontend-design` |
| `shadcn` | "shadcn/ui" "组件" | `frontend-design` |
| `canvas-design` | "海报" "艺术作品" | `algorithmic-art` |
| `algorithmic-art` | "生成艺术" "p5.js" | `canvas-design` |
| `chart-visualization` | "图表" "数据可视化" | `data-analysis` |

### 📄 Document / Content
| Skill | Trigger | Companion |
|---|---|---|
| `doc-coauthoring` | "写文档" "提案" "规格" | `consulting-analysis` |
| `consulting-analysis` | "市场分析" "投资" "竞品" | `data-analysis` |
| `defuddle` | "网页转 markdown" "抓内容" | `obsidian-markdown` |
| `report-generator` | "视频分析" "报告" | `hook-analyzer` |

### 🛠️ Data / Engineering
| Skill | Trigger | Companion |
|---|---|---|
| `data-analysis` | "Excel" "CSV" "数据分析" | `mcp_MySQL_*` |
| `agent-browser` | "浏览器" "自动化" "测试 web" | `dogfood` |
| `gh-cli` | "GitHub" "PR" "CI" | `mcp_GitHub_*` |
| `dogfood` | "QA" "找 bug" "测试应用" | `agent-browser` |
| `skill-creator` | "创建 skill" "新技能" | — |

### 💻 Code
| Skill | Trigger | Companion |
|---|---|---|
| `TRAE-code-review` | "代码审查" "review" | `TRAE-security-review` |
| `TRAE-security-review` | "安全扫描" "漏洞" | `TRAE-code-review` |
| `TRAE-generate-mini-app` | "小程序" "Taro" "微信" | — |

### 📚 Obsidian
| Skill | Trigger | Companion |
|---|---|---|
| `obsidian-cli` | "Obsidian" "笔记管理" | `obsidian-markdown` |
| `obsidian-markdown` | "wikilink" "callout" | `obsidian-cli` |
| `obsidian-bases` | ".base" "数据库视图" | `obsidian-cli` |
| `json-canvas` | ".canvas" "思维导图" | `obsidian-cli` |

## Layer 3: Tools (Native IDE Operations)

Built-in operations that don't require external capabilities.

| Tool | When to Use | Example |
|---|---|---|
| `Read` / `Write` / `Edit` | File I/O | 读写代码、配置文件 |
| `RunCommand` | Shell execution | `pdflatex`, `npm install`, `git` |
| `Glob` / `Grep` / `SearchCodebase` | Code search | 找文件、搜符号 |
| `Task` (subagent) | Parallel work | 多文件同时处理 |
| `Skill` | Load domain prompt | 激活专业领域知识 |
| `AskUserQuestion` | Clarification | 需求不明确时 |
| `WebSearch` / `WebFetch` | Web data | 搜索文档、抓网页 |
| `mcp_*` | External service | 数据库、API、搜索 |

## Decision Matrix: When to Use Which Layer

```
Request comes in
│
├─ Needs external data/service? (论文库、数据库、GitHub、网页)
│  └─ YES → MCP Layer
│      ├─ MCP available & healthy? → Use MCP
│      └─ MCP unavailable/placeholder? → Fallback to Skill or Tool
│
├─ Needs domain expertise/workflow? (TikZ、科研绘图、代码审查)
│  └─ YES → Skill Layer
│      ├─ Skill exists? → Use Skill
│      └─ Skill doesn't exist? → Tool Layer (native IDE ops)
│
└─ Simple operation? (读文件、跑命令、搜代码)
   └─ YES → Tool Layer (fastest, no setup)
```

## Semi-Autonomous Execution Modes

### Mode A: Auto-Invoke (Confidence ≥ 0.9)
When intent is crystal clear and capability is healthy:

```
User: "画个 Transformer 架构图放我论文里"
→ Intent: 科研插图 + LaTeX/TikZ + 出版级
→ Match: tikz-diagrams-guide (模板) + figura (风格)
→ Confidence: 0.95
→ Action: AUTO-INVOKE both skills
→ Output: "正在用 tikz-diagrams-guide 和 figura 为您生成..."
```

### Mode B: Recommend + Confirm (Confidence 0.7-0.9)
When intent is clear but choice matters:

```
User: "我想可视化一些数据"
→ Intent: 数据可视化 (模糊: matplotlib? TikZ? JS?)
→ Candidates: figura (matplotlib) / chart-visualization (JS) / data-analysis (Excel)
→ Confidence: 0.75
→ Action: RECOMMEND + ASK
→ Output: "建议用 figura (matplotlib, 适合论文) 或 chart-visualization (JS, 适合网页)。您要哪种？"
```

### Mode C: Interview (Confidence < 0.7)
When intent is ambiguous:

```
User: "帮我做个东西"
→ Intent: 完全不明
→ Confidence: 0.3
→ Action: INTERVIEW
→ Output: "想做什么类型的东西？1) 网站/应用 2) 数据分析 3) 论文/研究 4) 设计/图"
```

## Cross-Platform Compatibility

This router works across multiple AI coding platforms:

| Platform | Skill Path | MCP Config | Notes |
|---|---|---|---|
| **Trae** | `~/.trae-cn/builtin/global/skills/` + `<project>/.trae/skills/` | `mcp-config.json` | 当前平台 |
| **Claude Code** | `~/.claude/skills/` | `claude_desktop_config.json` | 需调整路径 |
| **Cursor** | `.cursor/skills/` | `cursor-mcp.json` | 实验性支持 |
| **VSCode + Cline** | `.cline/skills/` | `cline_mcp_settings.json` | 需手动配置 |

> **Migration**: To port to another platform, copy `SKILL.md` files to the platform's skill directory and update MCP references in the Environment section.

## Common Composition Recipes (MST Stack)

| # | 场景 | MCP | Skill | Tool |
|---|---|---|---|---|
| 1 | 找论文+读+整理 | `mcp_paper-search_*` → `mcp_semantic-scholar_*` | `literature-search` → `academic-research-assistant` | `Read` (读 PDF) |
| 2 | 画科研图+编译 | — | `tikz-diagrams-guide` → `figura` | `RunCommand` (pdflatex) |
| 3 | Excel数据→报告 | `mcp_MySQL_*` (如有数据库) | `data-analysis` → `consulting-analysis` | `Read` (读 Excel) |
| 4 | Figma→React代码 | — | `figma` → `frontend-design` → `shadcn` | `Write` (写组件) |
| 5 | 代码审查+安全 | — | `TRAE-code-review` + `TRAE-security-review` | `Read` (读 diff) |
| 6 | 网页→笔记 | — | `defuddle` → `obsidian-markdown` | `WebFetch` |
| 7 | 系统综述PRISMA | `mcp_paper-search_*` | `literature-search` → `academic-research-assistant` | `Task` (并行搜索) |
| 8 | Web app QA | — | `dogfood` + `agent-browser` | `RunCommand` (启动服务) |
| 9 | 搭SaaS落地页 | — | `web-dev` → `frontend-design` → `theme-factory` | `RunCommand` (npm) |
| 10 | 视频分析报告 | — | `hook-analyzer` → `report-generator` | `Read` (读视频) |
| 11 | 多模型代码生成 | `mcp_*` (如有AI router MCP) | `agent-swarm-orchestration` | `Task` (并行 agent) |
| 12 | 论文端到端发表 | `mcp_paper-search_*` + `mcp_semantic-scholar_*` | `literature-search` → `academic-research-assistant` → `figura` | `RunCommand` (latexmk) |

## Confidence Scoring

```
confidence = base_score × health_factor × context_factor

base_score:
  - Exact keyword match: 1.0
  - Semantic match: 0.8
  - Broad category match: 0.6
  - Ambiguous: 0.4

health_factor:
  - MCP healthy: 1.0
  - MCP placeholder/unavailable: 0.5
  - Skill installed: 1.0
  - Skill not installed: 0.0 (skip)

context_factor:
  - Previous turns confirm pattern: 1.2
  - First turn, no context: 1.0
  - Contradictory previous turns: 0.8
```

## Fallback Chain

When primary capability fails:

```
Primary (MCP) → Secondary (Skill) → Tertiary (Tool) → Manual (Ask User)

Example:
  mcp_latex-mcp-server_compile_latex (FAIL: placeholder)
  → figura (skill: 出版级图表规范)
  → RunCommand + pdflatex (tool: 直接编译)
  → "请手动运行 pdflatex" (last resort)
```

## Environment Registry (this machine)

Auto-detected capabilities:

```yaml
platform: Trae IDE
os: Windows
shell: PowerShell

mcp_status:
  mcp_paper-search: ✅ active
  mcp_semantic-scholar: ✅ active
  mcp_MySQL: ✅ active
  mcp_GitHub: ✅ active
  mcp_drawio-official: ✅ active
  mcp_latex-mcp-server: ⚠️ placeholder (python http.server)

latex:
  engine: MiKTeX 25.12
  binaries: [pdflatex, xelatex, latexmk]
  packages: [ctex, tikz, pgfplots, tikz-bayesnet, tikz-cd, smartdiagram, forest, algorithm2e, helvet]
  rasterizer: pdftoppm (poppler)

skills_installed:
  global: [TRAE-code-review, TRAE-generate-mini-app, TRAE-security-review, figura, skill-creator, skill-router, tikz-diagrams-guide]
  project: [academic-research-assistant, academic-research-skills/*, literature-search]
  builtin: [frontend-design, frontend-skill, web-dev, web-artisan, web-design-guidelines, web-design-docs, figma, shadcn, theme-factory, brand-guidelines, canvas-design, algorithmic-art, chart-visualization, doc-coauthoring, defuddle, report-generator, consulting-analysis, data-analysis, agent-browser, gh-cli, dogfood, hook-analyzer, json-canvas, obsidian-cli, obsidian-markdown, obsidian-bases]
```

## Output Format

When this skill is invoked, reply in this format:

```markdown
## 🧭 MST 路由建议

**意图分析**: <task type> | <complexity> | <urgency>
**置信度**: <0.0-1.0>
**执行模式**: <Auto / Recommend / Interview>

### 推荐路径
| 层级 | 选择 | 理由 |
|---|---|---|
| MCP | `<name>` / `—` | <为什么选/为什么不选> |
| Skill | `<name>` | <匹配点> |
| Tool | `<name>` | <操作方式> |

### 执行顺序
1. <第一步>
2. <第二步>
3. ...

### 备选方案
- 如果 `<primary>` 失败 → `<fallback>`

### 注意事项
- <MCP 健康状态 / 依赖 / 副作用>
```

## Constraints
- Never recommend more than 1 MCP + 2 Skills + 2 Tools in a single route
- Always check MCP health before recommending
- If confidence < 0.7, switch to Interview mode — don't guess
- Respect platform differences (Trae vs Claude Code vs Cursor)
- Update environment registry when new capabilities are installed
