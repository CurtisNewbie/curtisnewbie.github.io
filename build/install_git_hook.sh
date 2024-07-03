if [ ! -f .git/hooks/pre-commit ];then
    touch .git/hooks/pre-commit
else
    > .git/hooks/pre-commit
fi

echo "#!/bin/bash" >> .git/hooks/pre-commit
echo 'echo "Building jekyll"' >> .git/hooks/pre-commit
echo 'bundle exec jekyll build' >> .git/hooks/pre-commit
echo 'git add .' >> .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit