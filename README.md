
# Archie
## Simpler cross-compilation and testing for busy developers

_WARNING: THIS PROJECT IS STILL VERY MUCH A WORK-IN-PROGRESS AND SHOULD NOT BE USED FOR YOUR OWN PROJECTS YET. THERE'S A LOT OF PARTS MOVING AROUND. YE'VE BEEN WARNED!!_

[![GitHub Stars](https://img.shields.io/github/stars/headmelted/archie.svg)](https://github.com/headmelted/archie/stargazers)
[![GitHub Watchers](https://img.shields.io/github/watchers/headmelted/archie.svg)](https://github.com/headmelted/archie/watchers)
[![Docker Stars](https://img.shields.io/docker/stars/headmelted/archie.svg)](https://hub.docker.com/r/headmelted/archie/)
[![Docker Pulls](https://img.shields.io/docker/pulls/headmelted/archie.svg)](https://hub.docker.com/r/headmelted/archie/)
[![Build Status](https://dev.azure.com/headmelted/headmelted_on_github/_apis/build/status/headmelted.archie)](https://dev.azure.com/headmelted/headmelted_on_github/_build/latest?definitionId=4)

### What is Archie?
Archie is a series of pre-configured Debian Stretch docker containers that are collectively intended to make porting, compiling and testing code written for GNU compilers on multiple architectures as simple as possible.

By using some sensible defaults, and several commonly used and well-supported tools, Archie's goal is to make compiling platform-agnostic code in several languages to architectures such as ARM, PowerPC and SPARC as simple as building for Intel.

### Who should use Archie?
Certain projects are a better fit than others for the assumptions Archie makes.  Specifically, any code that relies heavily on architecture-specific calls is will see limited benefit from using Archie, whereas platform-agnostic code (or code with platform-agnostic native dependencies) is likely to have much better results.

It's expected that Archie should be able to compile fully platform-agnostic code to any target it supports without any changes, but any architecture-specific calls in your code will need to be patched to support your target.  In these cases, Archie can still help with migrating your project to support multiple architectures, but it isn't a silver bullet for deeply architecture-dependent code.

### How to get started
Typically, the easiest way to get started with Archie is to first try to migrate your existing build script to building inside Archie with the **amd64** target (i.e. an **amd64** to **amd64** build).  Once your scripts are correctly configured for Archie, and your project is compiling successfully for **amd64**, targeting other architectures should be as simple as adding a different target architecture from the Supported Architectures table to your configuration.

### Strategies
Archie supports three different strategies for working with a target architecture within a session, as explained below.  Each of these strategies are agnostic as to the structure of your code, such that you should be able to change the setting as required by your project without making changes to your own code.

#### cross
The session is executed using **amd64** GNU cross-compilers for the target architecture.  When using this strategy, the dependency packages for the target architecture are installed, and linked explicitly during compilation.

_This is the fastest strategy for compilation (broadly equivalent in performance to compiling directly to amd64 in the simplest cases), but may not play well with all dependencies of your project. During compilation, the $CC and $CXX variables commonly used to alias GCC are modified to explicitly include linking of the supporting dependencies for the target architecture.  While this is often all you'll need for cross-compilation, you may experience execution format errors that are likely a sign of native code (specific to the *target* architecture) trying to run during installation of a dependency. If this happens you'll need to choose another strategy._

#### hybrid
The session is executed similarly to the _cross_ strategy, but depedencies are installed within an emulated environment for the target architecture such that any native code called during installation of the dependencies will execute as expected. This is typically less performant than the *cross* method, but increases compatibility by emulating every call not made by the compiler.

_This is likely to be suitable for most cross-compilation scenarios, and would be the first thing to try if you encounter exec format errors with the *cross* strategy.  Compilation performance is mostly preserved as amd64-native compilers are still used, and emulation will only occur for dependency installation processes._

#### emulate
The session is executed inside an emulated environment for the target architecture. This is less performant than using the *hybrid* strategy, but increases compatibility further by transparently emulating every call.

_It may be necessary to switch from *hybrid* to *emulate* in certain cases where hard-coded logic inside your code or dependencies requires the target architecture specifically._

#### virtualize (work-in-progress)
The session is executed in a virtualized QEMU system that is running an image compiled explicitly for the target architecture.  This strategy has the highest compatibility, as all logic will be performed within the target architecture with effectively no trace of native host components - but at a significant performance cost due to the emulation overhead.

_This strategy is most useful in scenarios where you need to be able to confirm that your code can be compiled by downstream users with specific devices (e.g. specific niche processors, lower memory). An example of this is targeting the Raspberry Pi line of single-board computers, which can be completely virtualised within a session._

### Support matrix
#### Variables
Archie sets a series of global variables inside each session that can be used to help with your builds.  The table below explains these variables, and gives some context as to what each one means.  Note that Archie globals are always prefixed with *ARCHIE_* so as to prevent conflicts with your own variables **except** in limited instances where Archie intentionally overwrites global variables to make cross-compilation easier, these variables are in **bold**.

| Global                               | Description                                                               | cross | hybrid | emulate | virtualize | CI bindings
|--------------------------------------|---------------------------------------------------------------------------|-------|--------|---------|------------|-------
| $ARCHIE_ARCH                        | The target architecture of the current session                            | yes   | yes    | yes     | yes        | yes
| $ARCHIE_STRATEGY                    | The strategy of the current session                                       | yes   | yes    | yes     | yes        | yes
| $ARCHIE_OS_DISTRIBUTION_NAME        | The Linux distribution Archie is running on (currently *debian*)         | yes   | yes    | yes     | yes        | yes
| $ARCHIE_OS_RELEASE_NAME             | The Linux release Archie is running on (currently *stretch-slim*)        | yes   | yes    | yes     | yes        | yes
| $ARCHIE_CLEANROOM_ROOT_DIRECTORY    | The directory in which the architecture-specific cleanrooms are placed    | no    | no     | yes     | no         | no
| $ARCHIE_CLEANROOM_RELEASE_DIRECTORY | A sub-directory of the cleanroom corresponding to the OS release          | no    | no     | yes     | no         | no
| $ARCHIE_CLEANROOM_DIRECTORY         | The directory of the cleanroom for the current session                    | no    | no     | yes     | no         | no
| $ARCHIE_OUTPUT_DIRECTORY            | This is where build artifacts should should be placed during compilation. | yes   | yes    | yes     | yes        | yes
| $ARCHIE_CODE_DIRECTORY              | This is where the source code for compilation is placed.                  | yes   | yes    | yes     | yes        | yes
| $ARCHIE_GNU_TRIPLET             | The GNU triplet for the current architecture (e.g. i686-linux-gnu for 32-bit x86).                  | yes   | yes    | yes     | yes        | yes
| $ARCHIE_HEADERS_GNU_TRIPLET              | The GNU triplet for headers for the current architecture (e.g. i386-linux-gnu for 32-bit x86).                 | yes   | yes    | yes     | yes        | yes
| **$PKG_CONFIG_PATH**                    | Search path for pkg-config. Archie binds this based on strategy.                    | n/a   | n/a     | n/a     | n/a        | n/a
| **$CC** and **$CXX**                                | The GNU C\C++ compilers. Bound based on strategy and target dependencies. | n/a | n/a | n/a | n/a | n/a
| **$npm_config_arch** and **$npm_config_target_arch** | The NPM architecture for nodejs applications. Bound based on strategy and target dependencies. | n/a | n/a | n/a | n/a | n/a

#### Architecture
There are effectively two lists of supported architectures for Archie. Compiling and testing of programs without dependendent packages (i.e. programs for which no dependencies need to be pulled from Debian repositories) is supported for the intersection of architectures of GCC and QEMU.

As Archie is built on Debian Stretch, the architectures supported for those programs which have dependencies on standard packages within the repository mirror those supported by the operating system.  To clarify, the table below shows the state of support for different architectures within Archie, and the level of support that's available in terms of APT packages for that architecture.

| Architecture  | Family   | Bit width        | cross   | hybrid  | emulate | virtualize | packages 
|---------------|----------|------------------|---------|---------|---------|------------|----------
| i386          | x86      | 32               | yes     | yes     | yes     | yes        | all      
| amd64         | x86      | 64               | faked * | yes     | yes     | yes        | all      
| armel         | ARM      | 32               | yes     | yes     | yes     | yes        | all      
| armhf         | ARM      | 32 _(hard fp)_   | yes     | yes     | yes     | yes        | all      
| arm64         | ARM      | 64               | yes     | yes     | yes     | yes        | all      
| mips          | MIPS     | 32 _(be)_        | yes     | yes     | yes     | yes        | all      
| mipsel        | MIPS     | 32 _(le)_        | yes     | yes     | yes     | yes        | all      
| mips64        | MIPS     | 64               | yes     | yes     | yes     | yes        | all      
| ppc64el       | POWER    | 64               | yes     | yes     | yes     | yes        | all      
| s390x         | IBM Z    | 64               | yes     | yes     | yes     | yes        | all      

*\* The amd64 target does not actually involve cross-compilation, and simply maps directly to the x86_64 GCC compilers.  The target is included so that the the developer's build process can treat amd64 as agnostically as other architectures in Archie.
