#!/bin/bash

> .git/hooks/pre-commit \
    && echo "#!/bin/bash" >> .git/hooks/pre-commit \
    && echo "echo \"Building jekyll\"" >> .git/hooks/pre-commit \
    && echo "bundle exec jekyll build" >> .git/hooks/pre-commit \
    && echo "git add ." >> .git/hooks/pre-commit \
    && echo "Installed pre-commit hook: .git/hooks/pre-commit" \
    && echo "Content:" \
    && echo \
    && cat .git/hooks/pre-commit \
    && chmod +x .git/hooks/pre-commit
