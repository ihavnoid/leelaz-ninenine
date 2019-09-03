# What

This is a fork of "[leela-zero](http://github.com/gcp/leela-zero/)" which tries to reduce the problem size into something that can be trained by people or organizations with limited resource (e.g., budget of less than $5,000 USD, or even a single desktop if you are patient enough).  In essence, this is a tweaked version which is essentially a 9x9 go, plus some other tweaks as necessary.

If you want the full 19x19 version, please go to http://github.com/gcp/leela-zero/ and look for a good weight file from http://zero.sjeng.org/.

# So, why the fork?

As stated on the leela-zero README file, training a network for a 19x19 go will take thousands of years' worth of compute time, unless you are some mega-corporation with millions of servers or with some dedicated chip design team.  This is not ideal for people to learn and try new ideas.  The goal is to provide a smaller problem set that may be reachable within an individual or a small university research group.

# Compiling

## Requirements

* GCC, Clang or MSVC, any C++14 compiler
* boost 1.58.x or later (libboost-all-dev on Debian/Ubuntu)
* BLAS Library: OpenBLAS (libopenblas-dev) or (optionally) Intel MKL
* zlib library (zlib1g & zlib1g-dev on Debian/Ubuntu)
* Standard OpenCL C headers (opencl-headers on Debian/Ubuntu, or at
https://github.com/KhronosGroup/OpenCL-Headers/tree/master/opencl22/)
* OpenCL ICD loader (ocl-icd-libopencl1 on Debian/Ubuntu, or reference implementation at https://github.com/KhronosGroup/OpenCL-ICD-Loader)
* An OpenCL capable device, preferably a very, very fast GPU, with recent
drivers is strongly recommended (OpenCL 1.2 support should be enough,
even OpenCL 1.1 might work). If you do not have a GPU, modify config.h in the
source and remove the line that says "#define USE_OPENCL".

## Example of compiling and running - Ubuntu

    # Test for OpenCL support & compatibility
    sudo apt install clinfo && clinfo

    # Clone github repo
    git clone https://github.com/ihavnoid/leelaz-ninenine/
    cd leelaz-ninenine/src
    sudo apt install libboost-all-dev libopenblas-dev opencl-headers ocl-icd-libopencl1 ocl-icd-opencl-dev zlib1g-dev
    make
    cd ..
    
    # An untrained, random neural net parameter is provided.  This really plays random moves.
    src/leelaz --weights example-data/initial_9x9.txt
    
# Weights format

The weights file is a text file with each line containing a row of coefficients.
The layout of the network is as in the AlphaGo Zero paper (except being a 9x9 board),
but any number of residual blocks is allowed, and any number of outputs (filters) per layer,
as long as the latter is the same for all layers. The program will autodetect
the amounts on startup. The first line contains a version number.

* Convolutional layers have 2 weight rows:
    1) convolution weights
    2) channel biases
* Batchnorm layers have 2 weight rows:
    1) batchnorm means
    2) batchnorm variances
* Innerproduct (fully connected) layers have 2 weight rows:
    1) layer weights
    2) output biases

 The convolution weights are in [output, input, filter\_size, filter\_size] order,
 the fully connected layer weights are in [output, input] order.
 The residual tower is first, followed by the policy head, and then the value head.
 All convolution filters are 3x3 except for the ones at the start of the policy and
 value head, which are 1x1 (as in the paper).

There are 18 inputs to the first layer, instead of 17 as in the paper. The
original AlphaGo Zero design has a slight imbalance in that it is easier
for the black player to see the board edge (due to how padding works in
neural networks). This has been fixed in Leela Zero. The inputs are:

```
1) Side to move stones at time T=0
2) Side to move stones at time T=-1  (0 if T=0)
...
8) Side to move stones at time T=-7  (0 if T<=6)
9) Other side stones at time T=0
10) Other side stones at time T=-1   (0 if T=0)
...
16) Other side stones at time T=-7   (0 if T<=6)
17) All 1 if black is to move, 0 otherwise
18) All 1 if white is to move, 0 otherwise
```

Each of these forms a 9 x 9 bit plane.

The training/tf directory contains a 10 residual block version in TensorFlow format, in the tfprocess.py file.

# Training

## Getting the data

In addition to the methods described on Leela-zero README file,  leelaz-ninenine has an `autotrain` command which automatically runs a given number of games and then stores the training data with the given name.

See minitrain.sh for an example how this command is used.

## Training data format

The training data consists of files with the following data, all in text
format:

* 16 lines of hexadecimal strings, each 81 bits longs, corresponding to the
first 16 input planes from the previous section
* 1 line with 1 number indicating who is to move, 0=black, 1=white, from which
the last 2 input planes can be reconstructed
* 1 line with 82 (9x9 + 1) floating point numbers, indicating the search probabilities
(visit counts) at the end of the search for the move in question. The last
number is the probability of passing.
* 1 line with either 1 or -1, corresponding to the outcome of the game for the
player to move

## Training the data

The training/tf path contains the TensorFlow code which reads the latest 20% of the data available from the given glob,
runs 12000 batches, saves the state, and auto-terminates.  The intention is that we keep add more data from the self-play (minitrain.sh script) by restarting the training sequence every 12000 batches.  See training/tf/trainpipe.sh for an example.

# Related links

* The full 19x19 project
http://github.com/gcp/leela-zero/
* Status page of the original leela-zero distributed effort:
http://zero.sjeng.org

# License

The code is released under the GPLv3 or later, except for ThreadPool.h, cl2.hpp and the clblast_level3 subdir, which have specific licenses (compatible with GPLv3) mentioned in those files.
