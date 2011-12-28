
Experiments with Layering Components
====================================
Author: Brad Bowman

This is a small experiment in building layered components
that can be assembled together at run-time (initialization time, really).
The aim is to have small, single purpose components that can be
assembled into a variety of chains.  A common interface or protocol
exists along the chain, although it may be different from the presented
user interface (plumbing vs porcelain).  Long, thin chains where many
layers pass-through most of the interface are imagined.

While most of the experiments here are base on abusing inheritance,
simple object delegation is likely to be better most of the time.

* Ordering is important, making it trickier w/ roles
* Components that implement subsets of the interface and pass-through the rest
* Shared tails - if the last n layers are the same, they could be shared
* This isn't especially Moose-y although it's used for run-time class building

There are a number of pipeline or plugin modules out there to consider.

Warning: A lot of this was just stumbling around until the code seemed to work.
Don't think I know what I'm doing.

Where to Start
--------------

Look in the t/ directory first, ./t/manual-chain.t and ./t/data-chain.t
then ./lib/Chainer.pm, ./lib/Protocol.pm is just get and set.

$ tree -f
.
├── ./README.txt
├── ./chain.yaml
├── ./cmds.txt
├── ./experiments
│   ├── ./experiments/clone-lex.pl
│   ├── ./experiments/file-line.pl
│   ├── ./experiments/methods.pl
│   ├── ./experiments/two-face.pl
│   └── ./experiments/two-self.pl
├── ./lib
│   ├── ./lib/ArrayCache.pm
│   ├── ./lib/ArrayStore.pm
│   ├── ./lib/Chainer.pm
│   ├── ./lib/HashStore.pm
│   ├── ./lib/ParenMW.pm
│   └── ./lib/Protocol.pm
└── ./t
    ├── ./t/data-chain.t
    └── ./t/manual-chain.t

