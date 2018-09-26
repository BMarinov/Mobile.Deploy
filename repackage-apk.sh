#!/bin/bash
set -e # exit on first error.
packagePath=$1
envName=$2
keystorePath=$3
keyAlias=$4
keystorePass=$5

echo " (i) packagePath: $packagePath"
echo " (i) envName: $envName"
echo " (i) keystorePath: $keystorePath"
echo " (i) keyAlias: $keyAlias"
echo " (i) keystorePass: $keystorePass"
echo " (i) appName: $appName"
echo " (i) displayName: $displayName"

# Teardown trap runs regardless of exit code
function teardown {
    echo "Cleaning up."
    echo "note: this runs whether the script fails or not."
    /usr/bin/security delete-keychain $tempKeyChainPath || true
    rm -rf $SCRATCH || true
}
trap teardown EXIT

function initialize {
    echo " (i) Installing Apktool"
    brew install apktool
    
    echo " (i) Creating scratch directory"
    SCRATCH=$(mktemp -d)
    echo " (i) Scratch directory located at '$SCRATCH'"
}

function extractPackage {
    echo " (i) Decompiling $packagePath"
    apktool d "$packagePath" -o "$SCRATCH/apk"
}

function applyConfiguration {
    if [ ! -z "$envName" ] ; then
        envConfig="app.$envName.config"
        echo " (i) envConfig: $envConfig"
        keepFile="$envConfig.keep"

        echo " (i) Rename $envConfig to $keepFile"
        mv "$SCRATCH/apk/assets/$envConfig" "$SCRATCH/apk/assets/$keepFile"

        echo " (i) Remove .config files"
        rm "$SCRATCH/apk/assets/*.config"

        echo " (i) Rename .keep to app.config"
        mv "$SCRATCH/apk/assets/$keepFile" "$SCRATCH/apk/assets/app.config"
    fi
}

function packageApp {
    unalignedPath="$apkPath.unaligned"
    unsignedPath="$apkPath.unsigned"

    echo " (i) Repackage apk to $unsignedPath"
    apktool b apk -o $unsignedPath

    echo " (i) Sign $unsignedPath"
    jarsigner -keystore $keystorePath -storepass $keystorePass -keypass $keystorePass -verbose -sigalg MD5withRSA -digestalg SHA1 -signedjar $unalignedPath $unsignedPath $keyAlias
    jarsigner -verify -verbose -certs $unalignedPath

    echo " (i) Zipalign $unalignedPath"
    $ANDROID_HOME/build-tools/27.0.3/zipalign -f -v 4 $unalignedPath $apkPath
}


initialize

extractPackage

applyConfiguration

#setVersion

#updateDisplayName

packageApp

echo " (i) Move package back to $packagePath"
mv $SCRATCH/apk.apk $packagePath