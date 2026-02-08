#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2016 LEDE project
#
# Download script for repositories of all kinds. Refactored from perl
#

import re
from sys import argv, stderr, stdout
import subprocess
from os import path, environ, system, unlink
import signal
import random

def fn_hash_cmd(file_hash):
    file_hashlen = len(file_hash)
    if file_hashlen == 64:
        return environ['MKHASH'] + " sha256"
    elif file_hashlen == 32:
        return environ['MKHASH'] + " md5"
    else:
        return None

def localmirrors():
    ''' Obsolete stuff.
        Does anybody remeber about feature of overriding of mirrors?
    '''
    mirrors = []
    fn = path.join(argv[0], "localmirrors")
    if path.exists(fn):
        with open(fn, "r") as f:
            lines = f.readlines()
        for line in lines:
            linestrip = line().strip()
            if len(linestrip) > 0 and linestrip[0] != '#':
                mirrors.append(linestrip)
    fn = path.join(environ["TOPDIR"], ".config")
    if path.exists(fn):
        rg = re.compile(r"^CONFIG_LOCALMIRROR=(.+)")
        with open(fn, "r") as f:
            lines = f.readlines()
        for line in lines:
            m = rg.match(line)
            if m is not None:
                mirrors.extend(m.group(1).split(';'))
    if environ["TOPDIR"] is not None:
        mirrors.extend(environ["TOPDIR"].split(';'))
    return mirrors

def getcmdout(cmdlist):
    proc = subprocess.Popen(cmdlist, stdout=subprocess.PIPE)
    return [proc.communicate()[0], proc.returncode]

# not used. But better than 'tool_present'
def which(cmd):
    return getcmdout(["command", "-v", cmd])[0]

def tool_present(tool_name, compare_line):
    out = getcmdout([tool_name, "--version"])[0]
    if re.match(compare_line, out) is not None:
        return True
    return False

def select_tool():
    custom_tool = environ["DOWNLOAD_TOOL_CUSTOM"]
    
    if custom_tool is not None:
        return custom_tool.replace('"', '')
    # Try to use curl if available
    if tool_present("curl", "curl"):
        return "curl"
    # No tool found, fallback to wget
    return "wget"

def args_from_env(envvar):
    envvalue = environ[envvar]
    if envvalue is None:
        return []
    else:
        return [x for x in envvalue.split[' '] if x]
    
def char_array():
    return \
        [chr(x) for x in range(ord('a'), ord('z')+1)] + \
        [chr(x) for x in range(ord('A'), ord('Z')+1)] + \
        [chr(x) for x in range(ord('0'), ord('9')+1)]

def download_cmd(url, filename, additional_mirror_urls):
    download_tool = select_tool()
    check_certificate = environ["DOWNLOAD_CHECK_CERTIFICATE"] == "y"

    if download_tool == "curl":
        return ["curl", "-f", "--connect-timeout", "20", "--retry", "5", "--location"] + \
            ['--insecure'] if check_certificate else [] + args_from_env('CURL_OPTIONS') + \
            [url], False
    elif download_tool == "wget":
        return ["wget", "--tries=5", "--timeout=20", "--output-document=-"] + \
            ['--no-check-certificate'] if check_certificate else [] + args_from_env('WGET_OPTIONS') + \
            [url], False
    elif download_tool == "aria2c":
        
        additional_mirrors = " ".join([x + "/" + filename for x in additional_mirror_urls])
        random.seed()
        # random file name
        chArray = char_array()
        rfn = filename + "_" + [chArray[random.randrange(len(chArray))] for x in range(0, 9)]
        mirrors = []
        return [], True
        #return join(" ", "[ -d $ENV{'TMPDIR'}/aria2c ] || mkdir $ENV{'TMPDIR'}/aria2c;",
        #    "touch $ENV{'TMPDIR'}/aria2c/${rfn}_spp;",
        #    qw(aria2c --stderr -c -x2 -s10 -j10 -k1M), url, $additional_mirrors,
        #    check_certificate ? () : '--check-certificate=false',
        #    "--server-stat-of=$ENV{'TMPDIR'}/aria2c/${rfn}_spp",
        #    "--server-stat-if=$ENV{'TMPDIR'}/aria2c/${rfn}_spp",
        #    "--daemon=false --no-conf", shellwords($ENV{ARIA2C_OPTIONS} || ''),
        #    "-d $ENV{'TMPDIR'}/aria2c -o $rfn;",
        #    "cat $ENV{'TMPDIR'}/aria2c/$rfn;",
        #    "rm $ENV{'TMPDIR'}/aria2c/$rfn $ENV{'TMPDIR'}/aria2c/${rfn}_spp");
    else:
        return " ".join([download_tool, url])
    
def cleanup(foutname):
    unlink(f"{foutname}.dl")
    unlink(f"{foutname}.hash")

def _download(hash, target, filename, mirror, download_filename, additional_mirrors):
    foutname = path.join(target, filename)
    mirror = re.sub(r"/+$", "", mirror)
    
    mirror_file = re.sub(r"^file://", "", mirror)
    if mirror_file != mirror:
        if not path.exists(mirror_file):
            cleanup(foutname)
            raise ValueError(f"Wrong local cache directory -{mirror_file}-")
        if not path.exists(target):
            system(f"mkdir -p {target}")
        outlist = getcmdout(["find", mirror_file, "-follow", "-name", filename])
        out = outlist[0]
        ret = outlist[1]
        if out is None or out == "" or ret != 0:
            raise ValueError(f"Failed to search for {filename} in {mirror}")
        lines = out.split("\n")
        if len(lines) > 1:
            raise ValueError(f"{len(lines)} or more instances of {filename} in {mirror} found . Only one instance allowed")
        link = lines[0]
        if (link == ""):
            raise ValueError("No instances of {filename} found in $mirror")
        print(stdout, f"Copying $filename from {link}")
        system(f"cp {link} {foutname}.dl")
        if hash[0] is not None:
            if system(f"cat '{foutname}.dl' | {hash[0]} > '{foutname}.hash'") != 0:
                raise ValueError(f"Failed to generate hash for {filename}")
        all_mirrors = True
    else:
        cmd, all_mirrors = download_cmd(f"{mirror}/{download_filename}", download_filename, additional_mirrors)
        print(stderr, " ".join(cmd))
        outres = getcmdout(cmd)
        if outres[1] != 0 or (outres is None) or (outres[0] == ""):
            raise SystemError("Cannot launch aria2c, curl or wget.")
        with open(f"{foutname}.dl", "w") as f:
            f.write(outres[0])
        if hash[0] is not None:
            system(f"cat {foutname}.dl | {hash[0]} > {foutname}.hash")
    if hash[0] is not None:
        with open(f"{foutname}.hash", "r") as f:
            sum = f.read()
            patternmatch = re.fullmatch(r"^(\w+)\s*$", sum)
            if patternmatch is not None:
                sum = patternmatch.group(1)
            else:
                raise SystemError("Could not generate file hash")
            if (sum != hash[1]):
                cleanup(foutname)
                raise ValueError(f"Hash of the downloaded file does not match (file: {sum}, requested: {hash[1]}) - deleting download")
    unlink(foutname)
    system("mv {foutname}.dl {foutname}")
    cleanup(foutname)
    return True, all_mirrors

def download(hash, target, filename, mirror, download_filename, additional_mirrors):
    try:
        return _download(hash, target, filename, mirror, download_filename, additional_mirrors)
    except ValueError as ve:
        print(stderr, str(ve))
        return False, False
        

def sighandler(sig, frame):
    cleanup(path.join(argv[1], argv[2]))
    
LOCAL_MIRROR_SETTINGS = [
    {
        "pattern": r'^@SF/(.+)$',
        "urls": ['https://downloads.sourceforge.net' for x in range(1, 6)]
    },
    {
        "pattern": r'^@OPENWRT$',
        "urls": [
        ]
    },
    {
        "pattern": r'^@DEBIAN/(.+)$',
        "urls": [
            "https://ftp.debian.org/debian",
            "https://mirror.leaseweb.com/debian",
            "https://mirror.netcologne.de/debian",
            "https://mirrors.tuna.tsinghua.edu.cn/debian",
            "https://mirrors.ustc.edu.cn/debian"
        ]
    },
    {
        "pattern": r'^@APACHE/(.+)$',
        "urls": [
            "https://dlcdn.apache.org",
            "https://mirror.aarnet.edu.au/pub/apache",
            "https://mirror.csclub.uwaterloo.ca/apache",
            "https://archive.apache.org/dist",
            "https://mirror.cogentco.com/pub/apache",
            "https://mirror.navercorp.com/apache",
            "https://ftp.jaist.ac.jp/pub/apache",
            "https://apache.cs.utah.edu/apache.org",
            "http://apache.mirrors.ovh.net/ftp.apache.org/dist",
            "https://mirrors.tuna.tsinghua.edu.cn/apache",
            "https://mirrors.ustc.edu.cn/apache"
        ]
    },
    {
        "pattern": r'^@GITHUB/(.+)$',
        "urls": ['https://raw.githubusercontent.com' for x in range(1, 6)]
    },
    {
        "pattern": r'^@GNU/(.+)$',
        "urls": [
            "https://mirror.csclub.uwaterloo.ca/gnu",
            "https://mirror.netcologne.de/gnu",
            "https://ftp.kddilabs.jp/GNU/gnu",
            "https://www.nic.funet.fi/pub/gnu/gnu",
            "https://mirror.navercorp.com/gnu",
            "https://mirrors.rit.edu/gnu",
            "https://ftp.gnu.org/gnu",
            "https://mirrors.tuna.tsinghua.edu.cn/gnu",
            "https://mirrors.ustc.edu.cn/gnu"
        ]
    },
    {
        "pattern": r'^@SAVANNAH/(.+)$',
        "urls": [
            "https://mirror.netcologne.de/savannah",
            "https://mirror.csclub.uwaterloo.ca/nongnu",
            "https://ftp.acc.umu.se/mirror/gnu.org/savannah",
            "https://nongnu.uib.no",
            "https://cdimage.debian.org/mirror/gnu.org/savannah"
        ]
    },
    {
        "pattern": r'^@GNOME/(.+)$',
        "urls": [
            "https://download.gnome.org/sources",
            "https://mirror.csclub.uwaterloo.ca/gnome/sources",
            "https://ftp.acc.umu.se/pub/GNOME/sources",
            "http://ftp.cse.buffalo.edu/pub/Gnome/sources",
            "http://ftp.nara.wide.ad.jp/pub/X11/GNOME/sources",
            "https://mirrors.ustc.edu.cn/gnome/sources"
        ]
    },
]

LOCAL_MIRROR_SETTINGS_KERNEL = [
    "https://cdn.kernel.org/pub",
    "https://mirrors.mit.edu/kernel",
    "http://ftp.nara.wide.ad.jp/pub/kernel.org",
    "http://www.ring.gr.jp/archives/linux/kernel.org",
    "https://ftp.riken.jp/Linux/kernel.org",
    "https://www.mirrorservice.org/sites/ftp.kernel.org/pub",
    "https://mirrors.ustc.edu.cn/kernel.org"
]

LOCAL_MIRROR_SETTINGS_OWRT_FOR_ALL = [
    'https://sources.cdn.openwrt.org',
    'https://sources.openwrt.org',
    'https://mirror2.openwrt.org/sources'
]

def get_mirrors(filename):
    mirrors = localmirrors()
    
    for mirror in argv[3:]:
        for mirror_setting in LOCAL_MIRROR_SETTINGS:
            patternmatch = re.fullmatch(mirror_setting.get("pattern"), mirror)
            if patternmatch is not None:
                mirrors.extend([x + "/" + patternmatch.group(1) for x in mirror_setting.get("model")])
                break
        patternmatch = re.fullmatch('^\@KERNEL\/(.+)$', mirror)
        if patternmatch is not None:
            extra = [patternmatch.group(1)]
            if re.match(r"linux-\d+\.\d+(?:\.\d+)?-rc", filename) is not None:
                extra.append(extra[0] + "/testing")
            else:
                patternmatch = re.fullmatch(r'linux-(\d+\.\d+(?:\.\d+)?)', mirror)
                if patternmatch is not None:
                    extra.append(extra[0] + "/longterm/v" + patternmatch.group(1))
            mirrors.extend([x + "/" + y for x in LOCAL_MIRROR_SETTINGS_KERNEL for y in extra])
    mirrors.extend(LOCAL_MIRROR_SETTINGS_OWRT_FOR_ALL)
    return mirrors

def main():
    target = argv[1]
    filename = argv[2]
    file_hash = argv[3]
    if (len(argv) > 3) and (re.match(r'://', argv[4]) is not None):
        url_filename = argv[4]
    else:
        url_filename = filename
        
    hash_cmd = fn_hash_cmd(file_hash)
    
    if (hash_cmd is None) and (file_hash != "skip"):
        raise ValueError("Cannot find appropriate hash command, ensure the provided hash is either a MD5 or SHA256 checksum.\n")

    foutname = path.join(target, filename)
    if path.exists(foutname) and hash_cmd is not None:
        if system(r"cat '{1}' | ${2} > '{1}.hash'".format(foutname, hash_cmd)) != 0:
            raise ValueError(f"Failed to generate hash for {filename}\n")
        sum = getcmdout(["cat", r"{foutname}.hash"])[0]
        matchres = re.fullmatch(r'^(\w+)\s*', sum)
        if matchres is None:
            raise ValueError("Could not generate file hash\n")
        else:
            sum = matchres.group(1)
        cleanup(foutname)
        if sum == file_hash:
            return 0
        unlink(foutname)
        raise ValueError(f"Hash of the local file {filename} does not match (file: {sum}, requested: {file_hash}) - deleting download.\n")

    mirrors = get_mirrors(filename)

    have_file = False
    for mirror in mirrors:
        have_file, all_mirrors_done = download([hash_cmd, file_hash], target, filename, mirror, url_filename, mirrors)
        if (not have_file) and (url_filename != filename):
            have_file, all_mirrors_done = download([hash_cmd, file_hash], target, filename, mirror, filename, mirrors)
        if have_file or all_mirrors_done:
            break
    if not have_file:
        raise ValueError(f"No more mirrors to try for {filename} - giving up.\n")
    return 0

if __name__ == "__main__":
    signal.signal(signal.SIGINT, sighandler)
    try:
        main()
    except ValueError as ve:
        print(stderr, str(ve))
        exit(1)
    except SystemError as se:
        print(stderr, str(se))
        exit(1)