#!/bin/bash

cd ~/ymetrik.github.io
cp -r ~/SatelitPusat/html_leaf/* ~/ymetrik.github.io/leaf/

name=`date --utc`
git status
git add .
git commit -m "${name}"
git push -f --repo https://ymetrik:brambang_07@github.com/ymetrik/ymetrik.github.io.git 

cd ~/SatelitPusat/code