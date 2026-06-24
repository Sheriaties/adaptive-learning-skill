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
5. **写入 Obsidian**：所有概念笔记都写在 `03_Knowledge_Network/`，状态由 `understanding:` 字段 + tag 表达（黄=待验证、浅绿=简略、深绿=已掌握）。资料原文留在 `00_Sources/`。每个用户主动请求的学习根目标会自动生成一份 `04_MOC/` 学习地图，记录这次学习涉及哪些前置、各自状态。
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

### 两种安装方式

**方式 A：命令行下载**（适合习惯命令行的用户）。

**方式 B：对话内下载**（适合不想敲命令的用户，让 agent 帮你做）——把下面这段话发给你的 agent，它会自动 clone 仓库并启动 onboarding：

> 帮我安装 adaptive-learning skill：
> 1. 检测我用的是 Claude Code / OpenClaw / Hermes 中的哪一个
> 2. 把 https://github.com/Sheriaties/adaptive-learning-skill.git clone 到对应的 skills 目录
> 3. clone 完成后立刻读 SKILL.md 里的 "Step -1: Onboarding 对话" 段落，按那个脚本问我配置问题，最后生成 config.json + 创建 Vault 目录结构

> 三个生态对应的 skill 安装路径：
> - Claude Code → ~/.claude/skills/adaptive-learning/
> - OpenClaw → ~/.openclaw/workspace/skills/adaptive-learning/
> - Hermes Agent → ~/.hermes/skills/adaptive-learning/

**两种方式装完后都一样**：第一次说「我想学 X」时，agent 会先跑 onboarding 对话问你 3 个问题（Vault 路径、状态目录、session 尾巴字符），然后自动创建配置文件和 Vault 目录。**你不需要手写任何 JSON**。

---

### 方式 A 命令行：Claude Code

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.claude/skills/adaptive-learning
```

在 `~/.claude/CLAUDE.md` 加一段触发器：

```markdown
# adaptive-learning
- **adaptive-learning** (`~/.claude/skills/adaptive-learning/SKILL.md`) - 自适应学习工作流。Trigger: `/adaptive-learning`
When the user types `/adaptive-learning`, invoke the Skill tool with `skill: "adaptive-learning"` before doing anything else.
Also invoke when user expresses learning intent with phrases like: 想深入学习、想搞懂、系统学习、学习...架构、想深度学、从零开始学。
```

然后在 Claude Code 里直接说「我想学 X」即可触发 onboarding。

### 方式 A 命令行：OpenClaw

```bash
mkdir -p ~/.openclaw/workspace/skills
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.openclaw/workspace/skills/adaptive-learning
```

OpenClaw 会自动发现 `workspace/skills/` 下的 SKILL.md。在对话里用 `/adaptive-learning` 触发，或直接说"我想学 X"，agent 会按 SKILL.md 的描述匹配触发并跑 onboarding。

也可以从 [ClawHub](https://clawhub.ai)（OpenClaw 官方 skills registry）发布后供他人一键安装。

### 方式 A 命令行：Hermes Agent

Hermes 兼容 OpenClaw skill 格式。两种放置位置都可以：

```bash
# 推荐：直接放进 Hermes skills 目录
mkdir -p ~/.hermes/skills
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.hermes/skills/adaptive-learning

# 或：放进 openclaw-imports 子目录（如果你已有 OpenClaw 习惯，统一管理）
mkdir -p ~/.hermes/skills/openclaw-imports
git clone https://github.com/Sheriaties/adaptive-learning-skill.git ~/.hermes/skills/openclaw-imports/adaptive-learning
```

在 Hermes 里用 `/skills` 命令查看已注册 skills；用 `/adaptive-learning` 触发或表达学习意图自动触发，会先跑 onboarding。Hermes 还支持从 [agentskills.io](https://agentskills.io) 发现并安装。

---

## 配置

**通常你不需要手写 config.json**——首次运行 skill 时 agent 会通过对话引导你填，自动生成。下面只是字段说明，给想手动改的高级用户参考。

| 字段 | 含义 | 默认 |
|---|---|---|
| `vault_path` | Obsidian Vault 根目录 | `~/Documents/LearningVault/` |
| `state_dir` | 学习状态目录（含 user_profile.json + current_session.json） | `./.adaptive-learning/`（相对当前项目 cwd） |
| `session_suffix` | 每个 session 结尾追加的字符 | `喵`（设 `""` 关闭） |

**为什么 state_dir 默认相对 cwd？** 让每个项目维护自己的学习状态，跨项目不会互相污染。建议把 `.adaptive-learning/` 加入项目 `.gitignore`。如果你想多个项目共享一份学习画像，把 state_dir 改成绝对路径即可（例如 `~/.adaptive-learning/`）。

### Vault 目录结构

onboarding 完成时 agent 会**自动**在 `vault_path` 下 `mkdir -p` 出下面四个目录，并把笔记模板拷到 `99_Templates/`。**你不需要手动建任何目录**：

```
LearningVault/                  ← 你在 onboarding 时填的 vault_path
├── 00_Sources/                 ← 原始资料（仅联网模式）
│   └── <资料标题>.md            （frontmatter 含 source URL，2-3 句要点 + 与主题的关系）
│
├── 03_Knowledge_Network/       ← 全部概念笔记，state 由 frontmatter 表达，不靠目录区分
│   ├── <概念A>.md  (黄 pending-verify)   ← 占位 / 待验证
│   ├── <概念B>.md  (浅绿 understanding/brief)  ← 简略了解
│   └── <概念C>.md  (深绿 understanding/full)   ← 充分理解
│
├── 04_MOC/                     ← 学习地图，每个用户主动请求的根目标自动生成一份
│   └── <根目标> MOC.md          （记录前置层级、状态汇总，跟随学习进度自动更新）
│
└── 99_Templates/               ← agent 写笔记时参考的模板
    └── knowledge-note-template.md
```

另外在 `state_dir`（默认是当前项目 cwd 下的 `./.adaptive-learning/`）会有：

```
.adaptive-learning/             ← 学习状态（建议加进项目 .gitignore）
├── user_profile.json           ← 长期学习画像（已掌握的概念集合、学习历史）
└── current_session.json        ← 当前 session 的递归调用栈，用于断线恢复
```

**关键设计**：
- 概念的"已掌握 / 简略 / 待验证"状态完全由 `understanding:` 字段 + tag 表达，**不靠文件夹位置**——所以 03_Knowledge_Network 是单一目录，三种状态混在一起，靠 Graph View 颜色区分。
- 04_MOC 是导航层，不是知识本体——MOC 笔记不算"已学概念"，只是路径目录。
- 00_Sources 只在联网模式下使用；非联网模式不会有这个目录的内容。

### Obsidian Graph View 推荐配色

打开 Obsidian → Settings → Graph View → Groups，添加：

| Tag 查询 | 颜色 | 含义 |
|---|---|---|
| `tag:#understanding/full` | `#006400` 深绿 | 充分理解 |
| `tag:#understanding/brief` | `#5FF25F` 浅绿 | 简略了解 |
| `tag:#pending-verify` | `#FFFF00` 黄色 | 待确认 |
| `tag:#learning/root-request` | `#800080` 紫色 | 用户主动请求的根目标 |
| `tag:#moc` | `#FFA500` 橙色 | 学习地图（MOC，导航笔记） |

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
- **session 断线恢复未完全实现**：v0.1 把递归栈写到 `<state_dir>/current_session.json`，但恢复路径还在打磨中。
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
