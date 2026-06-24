# adaptive-learning

> 一个自适应学习 skill —— 把"想学 X"变成一条从资料搜集、理解验证到 Obsidian 知识网络的完整闭环。

支持 [Claude Code](https://github.com/anthropics/claude-code) / [OpenClaw](https://github.com/openclaw/openclaw) / [Hermes Agent](https://github.com/NousResearch/hermes-agent)（遵循 [agentskills.io](https://agentskills.io) 标准）。每个 session 结尾会加「喵」。

---

## 是什么

`adaptive-learning` 是一个 agent skill。当你说"我想搞懂 X"，它会：

1. **分层前置**：找出理解 X 之前必须先懂的概念，按依赖关系分 2-4 层呈现
2. **让你选**：每个前置概念你可以选 详细学 / 简略了解 / 跳过 / 已掌握
3. **递归学习**："详细学"会把那个前置当成新目标重新走一遍流程，递到底再回来
4. **理解验证**：先在对话里讲一遍，再开放答疑，最后小测——通过才算学会
5. **写入 Obsidian**：验证通过的知识进 `03_Knowledge_Network/`，未验证的留在 `02_Unknown/`，资料原文留在 `00_Sources/`
6. **图谱可视化**：通过 Obsidian Graph View 颜色（黄=待验证、浅绿=简略、深绿=已掌握）一眼看到学习状态

核心价值不是"让 AI 帮你写笔记"，而是**防止"读了就以为懂了"的伪学习污染你的知识网络**。

---

## 安装

### 前置要求

支持的 agent 框架（任选一个）：
- [Claude Code](https://github.com/anthropics/claude-code) CLI
- [OpenClaw](https://github.com/openclaw/openclaw)
- [Hermes Agent](https://github.com/NousResearch/hermes-agent)（OpenClaw 的官方继任）

笔记浏览：
- [Obsidian](https://obsidian.md/)（用来浏览 Vault 和看 Graph View）

> **格式说明**：本 skill 遵循 [agentskills.io](https://agentskills.io) 的 `SKILL.md` 开放标准。同一份代码三个生态都能跑，只是安装路径和触发方式略有差异。

### Claude Code 安装

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.claude/skills/adaptive-learning
cd ~/.claude/skills/adaptive-learning
cp config.example.json config.json
# 编辑 config.json 填入你的 Obsidian Vault 路径
```

在 `~/.claude/CLAUDE.md` 加一段触发器：

```markdown
# adaptive-learning
- **adaptive-learning** (`~/.claude/skills/adaptive-learning/SKILL.md`) - 自适应学习工作流。Trigger: `/adaptive-learning`
When the user types `/adaptive-learning`, invoke the Skill tool with `skill: "adaptive-learning"` before doing anything else.
Also invoke when user expresses learning intent with phrases like: 想深入学习、想搞懂、系统学习、学习...架构、想深度学、从零开始学。
```

### OpenClaw 安装

```bash
mkdir -p ~/.openclaw/workspace/skills
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.openclaw/workspace/skills/adaptive-learning
cd ~/.openclaw/workspace/skills/adaptive-learning
cp config.example.json config.json
# 编辑 config.json 填入你的 Obsidian Vault 路径
```

OpenClaw 会自动发现 `workspace/skills/` 下的 SKILL.md。在对话里用 `/adaptive-learning` 触发，或直接说"我想学 X"，agent 会按 SKILL.md 的描述匹配触发。

也可以从 [ClawHub](https://clawhub.ai)（OpenClaw 官方 skills registry）发布后供他人一键安装。

### Hermes Agent 安装

Hermes 兼容 OpenClaw skill 格式。两种安装方式：

**A. 直接放进 Hermes skills 目录**：

```bash
mkdir -p ~/.hermes/skills
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.hermes/skills/adaptive-learning
cd ~/.hermes/skills/adaptive-learning
cp config.example.json config.json
```

**B. 放进 openclaw-imports 子目录**（如果你已有 OpenClaw 习惯，统一管理）：

```bash
mkdir -p ~/.hermes/skills/openclaw-imports
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.hermes/skills/openclaw-imports/adaptive-learning
cd ~/.hermes/skills/openclaw-imports/adaptive-learning
cp config.example.json config.json
```

在 Hermes 里用 `/skills` 命令查看已注册 skills；用 `/adaptive-learning` 触发，或表达学习意图自动触发。Hermes 还支持从 [agentskills.io](https://agentskills.io) 发现并安装。

---

## 配置

`config.json` 字段：

| 字段 | 含义 | 默认 |
|---|---|---|
| `vault_path` | Obsidian Vault 根目录 | `~/Documents/LearningVault/` |
| `user_profile_path` | 长期学习画像 JSON | `~/.adaptive-learning/state/user_profile.json` |
| `session_state_path` | 当前 session 递归栈（断线恢复） | `~/.adaptive-learning/state/current_session.json` |
| `session_suffix` | 每个 session 结尾追加的字符 | `喵`（设 `""` 关闭） |

### Vault 目录结构

skill 会按需在 `vault_path` 下创建：

```
LearningVault/
  00_Sources/           ← 原始资料（联网模式）
  02_Unknown/           ← 待确认理解（学习中间站）
  03_Knowledge_Network/ ← 已验证知识（按 understanding level tag）
  04_MOC/               ← Maps of Content
  99_Templates/         ← 笔记模板
```

### Obsidian Graph View 推荐配色

打开 Obsidian → Settings → Graph View → Groups，添加：

| Tag 查询 | 颜色 | 含义 |
|---|---|---|
| `tag:#understanding/full` | `#006400` 深绿 | 充分理解 |
| `tag:#understanding/brief` | `#5FF25F` 浅绿 | 简略了解 |
| `tag:#pending-verify` | `#FFFF00` 黄色 | 待确认 |
| `tag:#learning/root-request` | `#800080` 紫色 | 用户主动请求的根目标 |

---

## 用法

在 Claude Code 里直接说想学什么：

```
/adaptive-learning 我想搞懂 Transformer 架构
```

或者直接用自然语言：

```
我想深入学习一下 Self-Attention
```

skill 会引导你完成：搜索决策 → 前置分层 → 你选学习粒度 → 资料搜集 → 讲课 → 答疑 → 小测 → 写入知识网络。

---

## 已知限制

- **目前仅支持中文 UI**：所有提示和笔记模板是中文。
- **不做自动去重**：v0.1 只用文件名查重 + `aliases` 字段。Vault 超过 200 篇笔记时建议接入第三方 dedup 工具。
- **不做图谱算法分析**：路径、孤立节点、社区检测请用 Obsidian 自带的 Graph View 或 [obsidian-graph-query](https://github.com/HEmile/juggl) 等成熟工具。
- **依赖模型自觉**：反幻觉守则、前置严格判定都是 prompt 层约束，不是硬保证。
- **session 断线恢复未完全实现**：v0.1 把递归栈写到 `session_state_path`，但恢复路径还在打磨中。
- **不支持自动多设备同步**：如果 Vault 在 iCloud / Dropbox 上，注意路径含空格时所有 Bash 命令要加双引号。

---

## 设计原则

- **Occam's Razor**：能用一条 skill 规则解决的，不写工具
- **不重复造轮子**：Obsidian 读写、Markdown 规范、网页搜索都用现成能力
- **保持 skill 轻量**：`SKILL.md` 只管工作流，模板/范文/角色拆到子目录
- **小步迭代**：v0.1 不追求完美，先能跑

完整设计哲学见 `SKILL.md` 顶部和 [evaluator role](.claude/roles/evaluator.md)（如果你 fork 时带过来）。

---

## 反馈

- Bug / 改进建议：开 GitHub Issue
- 你自己的 Vault 用法、你的 Obsidian 配色截图：欢迎在 Discussions 分享

---

## License

MIT。详见 [LICENSE](LICENSE)。
