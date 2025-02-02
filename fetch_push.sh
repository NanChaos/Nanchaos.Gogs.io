#!/bin/bash

# 确保在Git仓库中
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: This script must be run inside a Git repository."
    exit 1
fi

# 尝试fetch并检查是否有新的远程提交
REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
if [ -z "$REMOTE_BRANCH" ]; then
    echo "Error: Current branch has no upstream branch."
    exit 1
fi

git fetch
FETCH_HEAD=$(git rev-parse FETCH_HEAD^0) # FETCH_HEAD指向的是一个merge commit，所以我们取它的第一个父提交
CURRENT_HEAD=$(git rev-parse HEAD)

if [ "$FETCH_HEAD" != "$CURRENT_HEAD" ]; then
    echo "Fetched new commits from $REMOTE_BRANCH."
    # 这里可以添加代码来处理可能的合并冲突，但脚本将假设用户会手动处理这些冲突
else
    echo "No new commits to fetch."
fi

# 检查是否有未推送的commit
if git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD &> /dev/null; then
    echo "There are local commits to push."

    # 推送提交
    git push
    if [[ $? -eq 0 ]]; then
        echo "Local commits pushed successfully."
    else
        echo "Error: Failed to push local commits."
        exit 1
    fi
else
    echo "No local commits to push."
fi