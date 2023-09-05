#!/bin/bash

if ! command -v git-secrets >/dev/null; then
  echo "git-secrets 설치 중..."
  
  # Windows(git bash)용
  if [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
    brew install git-secrets
  fi
fi

PLANETARIUM_DIR="$HOME/.planetarium"

mkdir -p $PLANETARIUM_DIR

cat << EOF > $PLANETARIUM_DIR/fetch-patterns.sh
#!/bin/bash
curl -s https://raw.githubusercontent.com/planetarium/git-secrets-planetarium-provider/main/patterns.txt
EOF

chmod +x $PLANETARIUM_DIR/fetch-patterns.sh

git secrets --add-provider --global $PLANETARIUM_DIR/fetch-patterns.sh

GIT_TEMPLATE_DIR="$HOME/.git-templates/git-secrets"
mkdir -p $GIT_TEMPLATE_DIR
git secrets --install $GIT_TEMPLATE_DIR

git config --global init.templateDir $GIT_TEMPLATE_DIR

read -p "git-secrets의 hooks를 설치할 최상위 디렉토리 경로를 입력하세요. 하위 디렉토리에 .git 폴더를 찾아 전부 설치합니다.: " TARGET_DIR
echo "$TARGET_DIR 폴더 하위에 모든 .git 폴더에 git secrets --install을 실행합니다."

find "$TARGET_DIR" -type d -name ".git" | while read repo; do
  echo "$repo에 설치 중"
  git secrets --install "$repo/.."
done

echo "설정 완료!"
