#!/usr/bin/env bash

git add . -A
git commit -m "automatic commit"
git push origin korean_37

git checkout -B gh-pages
git rebase korean_37

touch .nojekyll

echo '!build/' >> .gitignore
echo '!env/' >> .gitignore

cd Doc
make -e SPHINXOPTS="-D language='ko'" html
cd ..

git add . -A
git commit -m "build"
git push -f origin gh-pages
git reset --hard HEAD
git clean -f
git checkout korean_37
