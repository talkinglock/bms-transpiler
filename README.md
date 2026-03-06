## Black Mesa Source Transpiler ##

The *Black Mesa Source Transpiler* project (BMST) is designed to convert maps from *Black Mesa's* XenEngine into *Source 2013* with as minimal loss in quality as possible. It will achieve this by primarily using the [Refab](src/resources/refabs/readme.md) system.

While this project is designed for the *Black Mesa Source VR 2026* project, it should work with any Source 2013 instance as long as the base
Source classes are lightly modified.

## TECHNICAL ##

The BMST is primarily coded in Lua using the [LuaJIT](https://luajit.org/) (Just in time) compiler. You do not need to install Lua/LuaJIT to run the transpiler, as they are already included inside the project.