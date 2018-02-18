#!/bin/bash

cd /opt/pk2-pg

git config --global user.email $GIT_USER_EMAIL
git config --global user.name $GIT_USER_NAME
git config --global push.default simple
