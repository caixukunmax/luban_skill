# Luban 配置编辑器 Skill

帮助 AI 高效操作 Luban 游戏配置表，支持枚举、Bean、数据表的增删改查。

## 前置条件

1. 确保 Python 3.8+ 已安装
2. 安装依赖：
```bash
pip install openpyxl
```

## 使用方式

通过 `run_in_terminal` 执行 `scripts/luban_helper.py` 脚本。

**注意**：PowerShell 中使用分号 `;` 作为命令分隔符，不要使用 `&&`。

---

## 枚举操作

### 列出所有枚举
```bash
python scripts/luban_helper.py enum list --data-dir DataTables/Datas
```

### 查询枚举详情
```bash
python scripts/luban_helper.py enum get test.ETestQuality --data-dir DataTables/Datas
```

### 新增枚举
```bash
python scripts/luban_helper.py enum add test.EWeaponType --values "SWORD=1:剑,BOW=2:弓,STAFF=3:法杖" --comment "武器类型" --data-dir DataTables/Datas
```

**参数说明**：
- `name`: 枚举全名（包含模块，如 `test.EWeaponType`）
- `--values`: 枚举值，格式 `name=value:alias,name2=value2:alias2`
- `--comment`: 枚举注释
- `--flags`: 是否为标志枚举（可选）

### 删除枚举
```bash
python scripts/luban_helper.py enum delete test.EWeaponType --data-dir DataTables/Datas
```

---

## Bean 操作

### 列出所有 Bean
```bash
python scripts/luban_helper.py bean list --data-dir DataTables/Datas
```

### 查询 Bean 详情
```bash
python scripts/luban_helper.py bean get test.TestBean1 --data-dir DataTables/Datas
```

### 新增 Bean
```bash
python scripts/luban_helper.py bean add test.Weapon --fields "attack:int:攻击力,speed:float:攻击速度" --parent Item --comment "武器" --data-dir DataTables/Datas
```

**参数说明**：
- `name`: Bean 全名（包含模块）
- `--fields`: 字段定义，格式 `name:type:comment,name2:type2:comment2`
- `--parent`: 父类名称（可选）
- `--comment`: Bean 注释（可选）

### 删除 Bean
```bash
python scripts/luban_helper.py bean delete test.Weapon --data-dir DataTables/Datas
```

---

## 表操作

### 列出所有表
```bash
python scripts/luban_helper.py table list --data-dir DataTables/Datas
```

---

## 缓存操作

### 构建缓存
```bash
python scripts/luban_helper.py cache build --data-dir DataTables/Datas
```

### 清除缓存
```bash
python scripts/luban_helper.py cache clear --data-dir DataTables/Datas
```

---

## `__enums__.xlsx` 结构说明

所有枚举定义在同一个 sheet 中：

```
| ##var | full_name          | flags | unique | group | comment | tags | *items              |
|-------|-------------------|-------|--------|-------|---------|------|---------------------|
| ##var | name              | alias | value  | comment | tags  |      |                     |
| ##    | 全名              | 是否标志| 是否唯一 |       |         |      | 枚举名              |
|       | test.ETestQuality | False | True   |       |         |      | A | 白 | 1 | 最高品质 |
|       |                   |       |        |       |         |      | B | 黑 | 2 | 黑色的   |
```

**关键规则**：
- `full_name` 有值 = 枚举定义开始
- `full_name` 为空 = 上一枚举的枚举项
- `*items` 列（H列开始）= 枚举项数据

---

## `__beans__.xlsx` 结构说明

所有 Bean 定义在同一个 sheet 中：

```
| ##var | full_name       | parent | valueType | alias | sep | comment | tags | group | *fields      |
|-------|----------------|--------|-----------|-------|-----|---------|------|-------|--------------|
| ##var | name           | alias  | type      | group | comment | tags | variants |            |
| ##    | 全名           | 父类   | 是否值类型 | 别名  | 分隔符 | 字段名  | 别名 | 类型  | 分组 | 注释 |
|       | test.TestBean1 |        |           |       |     | 测试Bean|      | c     | x1 | int | 最高品质 |
|       |                |        |           |       |     |         |      |       | x2 | string | 黑色的 |
```

**关键规则**：
- `full_name` 有值 = Bean 定义开始
- `full_name` 为空 = 上一 Bean 的字段
- `*fields` 列（J列开始）= 字段数据

---

## 示例：AI 操作流程

### 用户请求：添加一个武器类型枚举

**AI 执行步骤**：

1. 先查询现有枚举，避免重复
```bash
python scripts/luban_helper.py enum list --data-dir DataTables/Datas
```

2. 添加新枚举
```bash
python scripts/luban_helper.py enum add test.EWeaponType --values "SWORD=1:剑,BOW=2:弓,STAFF=3:法杖" --comment "武器类型" --data-dir DataTables/Datas
```

3. 验证结果
```bash
python scripts/luban_helper.py enum get test.EWeaponType --data-dir DataTables/Datas
```

### 用户请求：添加一个武器 Bean

**AI 执行步骤**：

1. 查询现有 Bean
```bash
python scripts/luban_helper.py bean list --data-dir DataTables/Datas
```

2. 添加新 Bean
```bash
python scripts/luban_helper.py bean add test.Weapon --fields "attack:int:攻击力,speed:float:攻击速度,range:float:攻击范围" --comment "武器" --data-dir DataTables/Datas
```

3. 验证结果
```bash
python scripts/luban_helper.py bean get test.Weapon --data-dir DataTables/Datas
```

---

## 注意事项

1. **PowerShell 分隔符**：使用 `;` 而非 `&&`
2. **路径问题**：确保 `--data-dir` 指向正确的 `Datas` 目录
3. **枚举/Bean 名称**：需要包含模块名，如 `test.EWeaponType`
4. **删除前检查**：删除前确认没有其他地方引用该枚举/Bean
