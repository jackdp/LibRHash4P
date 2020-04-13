
# RHash / LibRHash

**RHash** is a console application for calculating various check- and hashsums, including CRC32, CRC32C, MD4, MD5, SHA1, SHA256, SHA512, SHA3, AICH, ED2K, DC++ TTH, BitTorrent BTIH, Tiger, GOST R 34.11-94, GOST R 34.11-2012, RIPEMD-160, HAS-160, EDON-R, and Whirlpool.
RHash is written in C and is really very fast.

RHash author: Aleksey Kravchenko  
RHash repository: https://github.com/rhash/RHash  
RHash license: [BSD Zero Clause License](https://github.com/rhash/RHash/blob/master/COPYING)

**LibRHash** is a library that "drives" the RHash and can be compiled into a separate DLL or SO library file.

# LibRHash4P

**LibRHash4P**: *LibRHash* for Pascal (Lazarus and Delphi).  
Tested on Lazarus 2.0.6 + FPC 3.0.4, Lazarus 2.0.7 + FPC 3.3.1 and Delphi 2009 - 10.3 Rio.

LibRHash4P consists of two main files:
1. `librhash.pas` - pascal unit that imports all functions from the LibRHash library.
2. `rhash4p.pas` - unit with the **TRHashFile** class for hashing files, and several helpful functions.

In the repository you can also find a [demonstration program](https://github.com/jackdp/LibRHash4P/tree/master/demo) and compiled [32 and 64-bit libraries](https://github.com/jackdp/LibRHash4P/tree/master/bin/librhash_1.3.8) for Windows (**DLL** files) and Linux (**SO** files).

Most libraries are compiled in two versions: with `-O2` and `-O3` optimization enabled. Libraries compiled with `-O3` optimization should generally be slightly faster, but in some special situations they may be slower. In general, you should test the "O2" and "O3" libraries and choose the best one for your needs.

Warning!
When calculating the EDONR512 hashsum with a hash buffer larger than 8KiB, incorrect results are sometimes returned. That is why in the **TRhashFile** class I introduced buffer size control if the hash EDONR512 was selected.

If you need a very fast hash library, you should definitely pay attention to the LibRHash library.

# LibRHash4P License

The license for my work is the simplest in the world: **You can do with my code whatever you want without any cost and without any limitations.**

# Demo application - Screenshots

Demo application on Linux

![Demo on Linux](librhash4p_linux.png)

---

Demo application on Windows

![Demo on Windows](librhash4p_windows.png)

# Changelog

 - 2019.12.09 - Initial release for RHash ver. 1.3.8
 - 2020.04.13 - Added compatibility with older Delphi versions: 2009 and 2010.
