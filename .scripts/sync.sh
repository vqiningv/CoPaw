#!/bin/bash
set -e

UPSTREAM_BRANCH="upstream/main"
TARGET_BRANCH="dev" # 合并到的目标分支
DATE_STAMP=$(date +%Y%m%d-%H%M%S)

echo "🔄 开始同步上游代码..."

# 1. 检查工作区是否干净
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ 错误：工作区有未提交的更改，请先提交或 stash。"
    exit 1
fi

# 2. 切换到目标分支
git checkout $TARGET_BRANCH

# 3. 【安全机制】创建备份分支
BACKUP_BRANCH="backup/sync-before-$DATE_STAMP"
echo "💾 创建备份分支：$BACKUP_BRANCH"
git branch $BACKUP_BRANCH

# 4. 获取上游最新
echo "⬇️  Fetching upstream..."
git fetch upstream

# 5. 更新本地上游跟踪分支
git branch -f upstream-main $UPSTREAM_BRANCH

# 6. 执行合并 (使用 --no-ff 保留合并历史)
echo "🔀 正在合并上游代码到 $TARGET_BRANCH..."

# 设置环境变量允许向保护分支提交（pre-commit hook 会检查）
export ALLOW_PROTECTED_COMMIT=true

# 如果发生冲突，脚本会停止，留给人工解决
if ! git merge upstream-main -m "chore: sync upstream at $DATE_STAMP" --no-ff; then
    echo "⚠️  发生冲突！请手动解决冲突。"
    echo "💡 解决后运行：git add . && git commit"
    echo "💡 如果放弃合并，运行：git merge --abort"
    exit 1
fi

# 7. 运行测试 (如果有 Makefile)
if [ -f "Makefile" ] && make -n test > /dev/null 2>&1; then
    echo "🧪 运行本地测试..."
    make test || echo "⚠️  测试未通过，请检查代码"
fi

# 8. 推送
echo "⬆️  推送到远程 $TARGET_BRANCH 分支..."
git push origin $TARGET_BRANCH

# 注意：备份分支仅保留在本地，不推送到远程
# 如需推送备份，请取消下行注释
# git push origin $BACKUP_BRANCH

echo "✅ 同步完成！备份分支：$BACKUP_BRANCH"