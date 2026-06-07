# Skill Router Lite

> 轻量级 Skill 路由 — 只做一件事：告诉你该用哪个 Skill。

## 特点

- **~5KB**: 一个文件，零依赖
- **纯决策树**: 没有 MCP/Tool 管理，没有置信度计算
- **5 秒响应**: 快速匹配，不问废话
- **向后兼容**: 与 skill-router-v3 共存，v3 会自动 fallback 到 lite

## 安装

```bash
# Trae
mkdir -p ~/.trae-cn/builtin/global/skills/skill-router-lite
curl -sSL https://raw.githubusercontent.com/Eastr5/skill-router-v3/main/packages/skill-router-lite/SKILL.md \
  -o ~/.trae-cn/builtin/global/skills/skill-router-lite/SKILL.md

# Claude Code
mkdir -p ~/.claude/skills/skill-router-lite
curl -sSL https://raw.githubusercontent.com/Eastr5/skill-router-v3/main/packages/skill-router-lite/SKILL.md \
  -o ~/.claude/skills/skill-router-lite/SKILL.md
```

## 使用

```
用户: 我该用啥 skill 画科研图？
AI:  🧭 推荐 tikz-diagrams-guide — TikZ 科研绘图模板
     理由: 你说"科研图"，命中学术研究 → 画图分支
```

## 与 v3 的区别

| | Lite | v3 |
|---|---|---|
| 大小 | ~5KB | ~15KB |
| 架构 | 单层决策树 | MST 三层 |
| MCP 管理 | ❌ | ✅ |
| Tool 编排 | ❌ | ✅ |
| 自进化 | ❌ | ✅ |
| 置信度 | ❌ | ✅ |
| 适用场景 | 快速问答 | 复杂任务 |

## 什么时候用 Lite？

- 只需要知道"我该用啥 skill"
- 不需要 MCP 状态检测
- 不需要 Tool 层管理
- 想要最快响应

## 许可证

MIT
