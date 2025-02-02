#!/bin/bash

# 设置提交信息
commit_message="Automated commit of all files in current directory and subdirectories"

# 设置远程分支名称（根据需要修改）
remote_branch="master"

# 1. 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
  echo "当前目录不是一个Git仓库。"
  exit 1
fi

# 2. 检查是否有未add的内容
unadded_files=$(git status --porcelain | grep -E '^ M ')
if [ ! -z "$unadded_files" ]; then
  echo "正在add所有变更..."
  git add .
  echo "已add所有变更。"
else
  echo "没有新增的变更，跳过add。"
fi

# 3. 检查是否有未commit的内容
uncommitted_changes=$(git status --porcelain --untracked-files=no)
if [ ! -z "$uncommitted_changes" ]; then
  echo "正在commit所有变更，使用消息: $commit_message"
  git commit -m "$commit_message"
  echo "已commit所有变更。"
else
  echo "没有新增的commit，跳过commit。"
fi

# 4. 检查remote_branch是否有没有push的内容
# 注意：这里我们假设当前分支已经跟踪了远程分支，并且远程分支名称正确。
# 如果不确定，可以使用 git branch -vv 来检查当前分支的跟踪信息。
unpushed_commits=$(git log origin/$remote_branch..HEAD --oneline)
if [ ! -z "$unpushed_commits" ]; then
  echo "正在push $remote_branch 的所有commit..."
  git push origin "$remote_branch"
  if [ $? -eq 0 ]; then
    echo "已push所有变更。"
  else
    echo "推送失败，请检查网络连接或远程仓库权限。"
    exit 1
  fi
else
  echo "没有新增的push，跳过push。"
fi

echo "操作完成。"