#!/bin/bash
set -e

# 配置区域 (请根据实际情况修改)
UPSTREAM_URL="git@github.com:agentscope-ai/CoPaw.git" # 上游仓库地址
DEFAULT_BRANCH="main"       # 上游主分支名
DEV_BRANCH="dev"        # 您的开发主分支

echo "🚀 开始初始化二次开发工作流..."

# 1. 检查是否已添加 upstream
if ! git remote | grep -q "upstream"; then
    echo "➕ 添加 upstream 远程仓库..."
    git remote add upstream "$UPSTREAM_URL"
else
    echo "✅ upstream 远程仓库已存在"
fi

# 2. 获取上游最新代码
echo "⬇️  Fetching upstream..."
git fetch upstream

# 3. 创建上游跟踪分支 (只读)
if ! git branch --list | grep -q "upstream-$DEFAULT_BRANCH"; then
    echo "🌿 创建上游跟踪分支 upstream-$DEFAULT_BRANCH..."
    git branch upstream-$DEFAULT_BRANCH upstream/$DEFAULT_BRANCH
fi

# 4. 确保本地 dev 分支存在
if ! git branch --list | grep -q "$DEV_BRANCH"; then
    echo "🌿 创建开发分支 $DEV_BRANCH..."
    git checkout -b $DEV_BRANCH upstream/$DEFAULT_BRANCH
    git push -u origin $DEV_BRANCH
else
    echo "✅ 开发分支 $DEV_BRANCH 已存在"
fi

# 5. 安装 Git Hooks
# echo "🔗 安装 Git Hooks..."
# if [ -f ".git-hooks/pre-commit" ]; then
#     cp .git-hooks/pre-commit .git/hooks/pre-commit
#     chmod +x .git/hooks/pre-commit
#     echo "✅ Git Hooks 已安装"
# else
#     echo "⚠️ 警告：未找到 .git-hooks/pre-commit 文件"
# fi

echo "✅ 初始化完成！"
echo "💡 提示：建议日常开发从 $DEV_BRANCH 分支创建新的 feature 分支，并合并回 $DEV_BRANCH 分支"

# 【分支发布策略】
# 可以使用 dev 分支发布至开发测试环境
# 生产环境发布请先将 dev 合并到 main 分支，并从 main 分支创建版本分支进行发布（特殊情况下也可以直接发布 main 分支，仅需保证发布前，dev 分支已经进行过充分测试验证），例如 v1.0.0