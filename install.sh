#!/usr/bin/env bash
#
# Author: petr.danecek@sanger
#
# List or install all prerequisities
#
# Usage:
#   ./install.sh DIR
#
# Example:
#   wget -qO- https://raw.githubusercontent.com/HurlesGroupSanger/trio-dnm-calling/refs/heads/main/install.sh | bash -s dir
#

if [ $# != 1 ]; then
    echo "Usage:"
    echo "  ./install.sh DIR"
    echo
    exit;
fi

dst_dir=$1
mkdir -p $dst_dir

download_main=0
script=$0
if [ $script != "bash" ]; then
    dir=`dirname $script`
    if [ "$dir" = ""  ]; then dir="."; fi
    dir=`realpath $dir`
    has_main=`cat $dir/.git/config | grep trio-dnm-calling.git`
    if [ "$has_main" = "" ]; then
        download_main=1;
        echo 'export PATH='$dst_dir'/trio-dnm-calling/src:$PATH' > $dst_dir/setenv.sh
    else
        echo 'export PATH='$dir'/src:$PATH' > $dst_dir/setenv.sh
    fi
else
    download_main=1
    echo 'export PATH='$dst_dir'/trio-dnm-calling/src:$PATH' > $dst_dir/setenv.sh
fi

echo "pushd $dst_dir"
pushd $dst_dir

# Download the components:
# - the main trio-dnm-calling pipeline
set -e
if [ $download_main = "1" ] && [ ! -e "trio-dnm-calling" ]; then
    git clone git@github.com:HurlesGroupSanger/trio-dnm-calling.git
fi
set +e

# - vr-runner pipeline
perl -MRunner -e1 2>/dev/null
if [ "$?" != "0" ]; then
    if [ ! -e vr-runner/modules ]; then
        git clone git@github.com:VertebrateResequencing/vr-runner.git
    fi
    echo 'export PATH='$dst_dir'/vr-runner/scripts:$PATH' >> $dst_dir/setenv.sh
    echo 'export PERL5LIB='$dst_dir'/vr-runner/modules:$PERL5LIB' >> $dst_dir/setenv.sh
fi

# - bcftools
version=1.21
bcftools --version >/dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ ! -e bcftools-$version/bcftools ]; then
        wget https://github.com/samtools/bcftools/releases/download/$version/bcftools-$version.tar.bz2
        tar xjf bcftools-$version.tar.bz2
        pushd bcftools-$version
        set -e
        ./configure && make -j
        set +e
        popd
    fi
    echo 'export PATH='$dst_dir'/bcftools-'$version':$PATH' >> $dst_dir/setenv.sh
    echo 'export BCFTOOLS_PLUGINS='$dst_dir'/bcftools-'$version'/plugins' >> $dst_dir/setenv.sh
fi

# - samtools
samtools --version >/dev/null 2>&1
if [ "$?" != "0" ]; then
    if [ ! -e samtools-$version/samtools ]; then
        echo "need samtools"
        wget https://github.com/samtools/samtools/releases/download/$version/samtools-$version.tar.bz2
        tar xjf samtools-$version.tar.bz2
        pushd samtools-$version
        set -e
        ./configure && make -j
        set +e
        popd
    fi
    echo 'export PATH='$dst_dir'/samtools-'$version':$PATH' >> $dst_dir/setenv.sh
fi

