
git checkout -b gh-pages
git rebase docs-korean
touch .nojekyll
echo '!Doc/build/' >> .gitignore
cd Doc
make html
