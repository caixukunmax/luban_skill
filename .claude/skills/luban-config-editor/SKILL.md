---
name: luban-config-editor
description: 操作Luban游戏配置表，支持枚举、Bean、数据表的增删改查。【强制使用场景】当用户提到以下任意关键词时必须使用此技能：配置表、数据表、道具表、技能表、奖励表、活动表、Excel表、xlsx、枚举、Bean、字段、数据行、表结构、导表、Luban、游戏配置、修改配置、改表、新增道具、添加技能、策划配置、游戏数据、配置数据。即使用户没有明确说"Luban"，只要是编辑游戏配置数据，也要使用此技能。
license: MIT
compatibility: Requires Python 3.8+ and openpyxl package
metadata:
  author: luban-tools
  version: "3.8.0"
---

# Luban 配置编辑器 Skill

帮助 AI 高效操作 Luban 游戏配置表，支持枚举、Bean、数据表的增删改查。

## 前置条件

1. 确保 Python 3.8+ 已安装
2. 安装依赖：`pip install openpyxl`

## 使用方式

```bash
python scripts/luban_helper.py <command> --data-dir <项目的Datas目录>
```

**注意**：PowerShell 中使用分号 `;` 作为命令分隔符，不要使用 `&&`。

### PowerShell JSON 参数问题

PowerShell 处理 JSON 字符串参数会有转义问题。**推荐使用 `--file` 参数从文件读取**：

```bash
# 方法1：从JSON文件读取（推荐）
python scripts/luban_helper.py row add TbItem --file item.json --data-dir ...

# 方法2：使用Python脚本调用
python -c "import json; ..."
```

---

## AI 操作工作流

### ⚠️ 操作前确认机制

当用户指令模糊时，**必须先确认再操作**：

| 场景 | 需要确认的内容 |
|------|---------------|
| "加个道具" | 确认表名、道具名、具体字段值 |
| "加个字段" | 确认表名、字段名、字段类型 |
| "删除xxx" | 确认删除目标、影响范围、二次确认 |
| "修改xxx" | 确认修改内容、影响的数据行 |

**确认模板**：
```
我将执行以下操作：
- 文件：xxx.xlsx
- 操作：新增数据行
- 内容：
  - id: 3007
  - name: 魔丸
  - type: Consumable
  - ...

确认执行吗？(是/否)
```

**多文件选择**：
```
找到多个可能的目标表：
1. TbItem (道具表) - #Item-道具表.xlsx
2. TbSkill (技能表) - #Skill-技能表.xlsx

请选择要操作的表？
```

### 首次操作项目时
1. 执行 `table list` 了解项目有哪些表
2. 执行 `enum list` 和 `bean list` 了解类型系统
3. 根据用户需求定位具体表

### 修改数据前
1. 先用 `table get` 或 `field list` 确认表结构
2. 用 `row get` 查询现有数据，避免主键冲突
3. 执行修改后用 `validate` 验证

### 删除操作前
1. 用 `ref` 检查引用关系
2. 提醒用户确认风险
3. 危险操作需要二次确认

### 智能推断指南

| 用户说 | 推断命令 |
|--------|---------|
| "查一下屠龙刀" | `row get TbItem --field name --value "屠龙刀"` |
| "道具表加个字段" | `field add TbItem <字段名> --type ...` |
| "删除道具1001" | `row get TbItem --field id --value 1001` 确认后删除 |
| "看看品质枚举" | 先 `enum list` 找到匹配项，再 `enum get` |
| "加个新道具" | `row add TbItem --data '{"id":...}'` |

---

## 常见错误速查

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| 找不到表 | 表名不带模块或拼写错误 | 用 `table list` 确认完整表名 |
| 主键冲突 | 添加的数据 id 已存在 | 先 `row get` 检查是否已存在 |
| 类型错误 | 数据格式不匹配字段类型 | 用 `table get` 确认字段类型 |
| 引用约束 | 删除被引用的枚举/Bean | 用 `ref` 检查引用关系 |
| 找不到枚举 | 未带模块名 | 用 `enum list` 确认完整名称 |

---

## 常见场景速查

| 场景 | 命令 |
|------|------|
| 查看项目有哪些表 | `table list` |
| 查看表结构 | `table get TbItem` |
| 查看所有枚举 | `enum list` |
| 查看枚举详情 | `enum get test.EItemQuality` |
| 查看所有 Bean | `bean list` |
| 查询 id=1001 的数据 | `row get TbItem --field id --value 1001` |
| 按条件查询数据 | `row query TbItem --conditions '{"type":"Weapon"}'` |
| 添加新字段 | `field add TbItem price --type int --comment 价格` |
| 删除字段（危险） | `field delete TbItem price` |
| 创建新表 | `table add test.TbEquip --fields "id:int,name:string"` |
| 创建纵表 | `table add test.TbConfig --fields "key:string,value:int" --vertical` |
| 添加数据行 | `row add TbItem --data '{"id":1001,"name":"宝剑"}'` |
| 添加数据行（从文件） | `row add TbItem --file item.json` |
| 导出表数据 | `export TbItem --output backup.json` |

**智能插入**：添加数据行时自动按 ID 顺序插入到合适位置，而非追加到末尾。
- ID 最大 → 追加到末尾
- ID 在中间 → 插入到合适位置

---

## 命令概览

| 命令 | 功能 | 示例 |
|------|------|------|
| `enum list/get/add/update/delete` | 枚举操作 | `enum get test.EQuality` |
| `bean list/get/add/update/delete` | Bean操作 | `bean get test.RewardItem` |
| `table list/get/add/update/delete` | 表操作 | `table get TbItem` |
| `field list/add/update/delete/disable/enable` | 字段操作 | `field add TbItem desc --type string` |
| `row list/get/query/add/update/delete` | 数据行操作 | `row get TbItem --field id --value 1` |
| `batch fields/rows` | 批量操作 | `batch rows TbItem --data '[...]'` |
| `export/import` | 导入导出 | `export TbItem --output backup.json` |
| `validate` | 验证表数据 | `validate TbItem` |
| `ref` | 引用检查 | `ref test.RewardItem` |
| `template` | 配置模板 | `template create item TbEquip` |
| `rename/copy/diff` | 表管理 | `rename TbItem TbItemNew` |
| `auto` | 自动导入表 | `auto create #Item --fields "..."` |
| `alias` | 常量别名 | `alias add GOLD 10000` |
| `tag` | 数据标签 | `tag add TbItem 2 dev` |
| `variant` | 字段变体 | `variant add TbItem name zh` |
| `multirow` | 多行结构 | `multirow TbReward items` |
| `type` | 类型查询 | `type "list<int>"` |
| `cache` | 缓存管理 | `cache build` |
| `pref` | 用户偏好 | `pref set prefer_auto_import true` |

---

## 核心操作示例

### 枚举操作

```bash
# 列出所有枚举
python scripts/luban_helper.py enum list --data-dir DataTables/Datas

# 查询枚举详情
python scripts/luban_helper.py enum get test.ETestQuality --data-dir DataTables/Datas

# 新增枚举
python scripts/luban_helper.py enum add test.EWeaponType --values "SWORD=1:剑,BOW=2:弓,STAFF=3:法杖" --comment "武器类型" --data-dir DataTables/Datas

# 删除枚举
python scripts/luban_helper.py enum delete test.EWeaponType --data-dir DataTables/Datas
```

### Bean 操作

```bash
# 列出所有 Bean
python scripts/luban_helper.py bean list --data-dir DataTables/Datas

# 查询 Bean 详情
python scripts/luban_helper.py bean get test.TestBean1 --data-dir DataTables/Datas

# 新增 Bean
python scripts/luban_helper.py bean add test.Weapon --fields "attack:int:攻击力,speed:float:攻击速度" --parent Item --comment "武器" --data-dir DataTables/Datas
```

### 表操作

```bash
# 列出所有表
python scripts/luban_helper.py table list --data-dir DataTables/Datas

# 查询表详情
python scripts/luban_helper.py table get test.TbItem --data-dir DataTables/Datas

# 新增配置表（默认自动导入格式）
python scripts/luban_helper.py table add test.TbItem --fields "id:int:道具ID,name:string:道具名称" --comment "道具表" --data-dir DataTables/Datas

# 创建纵表（单例表）
python scripts/luban_helper.py table add test.TbGlobalConfig --fields "guild_open_level:int:公会开启等级,bag_init_size:int:初始格子数" --comment "全局配置" --vertical --data-dir DataTables/Datas
```

### 字段操作

```bash
# 列出表的所有字段
python scripts/luban_helper.py field list test.TbItem --data-dir DataTables/Datas

# 添加字段（分组自动推断）
python scripts/luban_helper.py field add test.TbItem desc --type "string" --comment "道具描述" --data-dir DataTables/Datas

# 删除字段（危险操作，需确认）
python scripts/luban_helper.py field delete test.TbItem desc --data-dir DataTables/Datas

# 禁用/启用字段
python scripts/luban_helper.py field disable test.TbItem desc --data-dir DataTables/Datas
python scripts/luban_helper.py field enable test.TbItem desc --data-dir DataTables/Datas
```

**分组自动推断规则**：
- `c` (客户端): name, desc, icon, image, model, effect, sound, ui 等
- `s` (服务器): server, logic, damage, hp, mp, exp, level, rate 等
- `cs` (两者): id, 其他无法明确判断的字段

### 数据行操作

```bash
# 列出数据行
python scripts/luban_helper.py row list test.TbItem --data-dir DataTables/Datas

# 按字段值查询
python scripts/luban_helper.py row get TbItem --field id --value 1004 --data-dir DataTables/Datas

# 多条件查询
python scripts/luban_helper.py row query TbItem --conditions '{"type":"Weapon","quality":5}' --data-dir DataTables/Datas

# 添加数据行
python scripts/luban_helper.py row add test.TbItem --data '{"id":1001,"name":"宝剑","count":1}' --data-dir DataTables/Datas
```

---

## 自动导入表

Luban 支持文件名以 `#` 开头的 Excel 文件自动导入为表。

**命名规则**：
- `#Item.xlsx` → 表名 `TbItem`，记录类型 `Item`
- `#Item-道具表.xlsx` → 表名 `TbItem`，注释 `道具表`
- `reward/#Reward.xlsx` → 表名 `reward.TbReward`

```bash
# 列出自动导入的表
python scripts/luban_helper.py auto list --data-dir DataTables/Datas

# 创建自动导入表
python scripts/luban_helper.py auto create #Item --fields "id:int:ID,name:string:名称" --data-dir DataTables/Datas
```

---

## Excel 结构说明

### 数据表结构
```
| ##var   | id  | name   | count   |
| ##type  | int | string | int     |
| ##      | 道具ID | 道具名称 | 堆叠数量  |
| ##group | c   | c      | c       |  ← 可选
```

### 纵表结构（单例表）
```
| ##column |          |          |         |
| ##var    | ##type   | ##       | ##group |
| key      | string   | 配置键    | c       |
| value    | int      | 配置值    | s       |
```

### __enums__.xlsx 结构
- `full_name` 有值 = 枚举定义开始
- `full_name` 为空 = 上一枚举的枚举项
- `*items` 列（H列开始）= 枚举项数据

### __beans__.xlsx 结构
- `full_name` 有值 = Bean 定义开始
- `full_name` 为空 = 上一 Bean 的字段
- `*fields` 列（J列开始）= 字段数据

---

## 支持的类型

### 基本类型
`bool` `byte` `short` `int` `long` `float` `double` `string` `text` `datetime`

### 容器类型
`array<T>` `list<T>` `set<T>` `map<K,V>`

### 可空类型
在类型后加 `?`：`int?` `string?` `MyBean?`

---

## 危险操作说明

以下操作需要二次确认：

| 操作 | 说明 |
|------|------|
| `field delete` | 删除字段会同时删除该字段的所有数据 |
| `row delete` | 删除数据行不可恢复 |
| `enum delete` | 删除被引用的枚举会导致错误 |
| `bean delete` | 删除被引用的 Bean 会导致错误 |

使用 `--force` 可跳过确认，但请谨慎使用。

---

## 注意事项

1. **枚举/Bean 名称**：需要包含模块名，如 `test.EWeaponType`
2. **删除前检查**：删除前确认没有其他地方引用该枚举/Bean
3. **路径问题**：确保 `--data-dir` 指向正确的 `Datas` 目录

---

## 详细文档

- 完整命令文档：[references/commands.md](references/commands.md)
- 需求参考文档：[references/REFERENCE.md](references/REFERENCE.md)
