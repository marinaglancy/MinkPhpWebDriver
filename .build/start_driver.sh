#!/usr/bin/env bash

set -ex

# https://github.com/symfony/symfony/pull/35311
sed -ir 's/self::/static::/g' vendor/symfony/phpunit-bridge/Legacy/SetUpTearDownTraitForV5.php
sed -ir 's/self::/static::/g' vendor/symfony/phpunit-bridge/Legacy/SetUpTearDownTraitForV8.php

mkdir -p ./logs
rm -rf ./logs/*

case "$(uname -s)" in
    Linux*)     machine=linux;;
    Darwin*)    machine=mac;;
esac

if [ -z $BROWSER_NAME ]; then
    echo "Environment variable BROWSER_NAME must be defined"
    exit 1
fi;

if [[ $BROWSER_NAME == "chrome" && -z $CHROMEDRIVER_VERSION ]]; then
    echo "Environment variable CHROMEDRIVER_VERSION must be defined"
    exit 1
fi;

if [[ $BROWSER_NAME == "firefox" && -z $GECKODRIVER_VERSION ]]; then
    echo "Environment variable GECKODRIVER_VERSION must be defined"
    exit 1
fi;

if [[ "$BROWSER_NAME" = "chrome" && "$CHROMEDRIVER_VERSION" = "latest" ]]; then
    CHROMEDRIVER_VERSION=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE);
fi

if [[ "$BROWSER_NAME" = "chrome" ]]; then
    mkdir -p chromedriver;

    if [ $machine = "linux" ]; then
        machine="linux64"
    fi;

    if [ $machine = "mac" ]; then
        machine="mac64"
    fi;

    wget -q -t 3 "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_${machine}.zip" -O driver.zip;
    yes "y" | unzip -q driver.zip -d chromedriver/;
fi

if [[ "$BROWSER_NAME" = "firefox" && "$GECKODRIVER_VERSION" = "latest" ]]; then
    GECKODRIVER_VERSION=$(curl -sS https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep -E -o 'tag_name([^,]+)' | tr -d \" | tr -d " " | cut -d':' -f2);
fi

if [[ "$BROWSER_NAME" = "firefox" ]]; then
    mkdir -p geckodriver;

    if [ $machine = "linux" ]; then
        machine="linux64"
    fi;

    if [ $machine = "mac" ]; then
        machine="macos"
    fi;

    wget -q -t 3 "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-$GECKODRIVER_VERSION-${machine}.tar.gz" -O driver.tar.gz;
    tar -xf driver.tar.gz -C ./geckodriver/;
fi

if [ "$BROWSER_NAME" = "chrome" ]; then
    ./chromedriver/chromedriver --port=4444 --verbose --whitelisted-ips=  &> ./logs/webdriver.log &
elif [ "$BROWSER_NAME" = "firefox" ]; then
    ./geckodriver/geckodriver --host 127.0.0.1 -vv --port 4444 &> ./logs/webdriver.log &
else
    docker run --rm --network=host -p 4444:4444 "selenium/standalone-firefox:$SELENIUM_DRIVER" &> ./logs/selenium.log &
fi;