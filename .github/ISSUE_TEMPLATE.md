If you are reporting a bug, please make sure to include the following information:
- [ ] Platform information (e.g. Ubuntu 20.04):
- [ ] CPU architecture (e.g. amd64):
- [ ] pungi version:
- [ ] Python version:
- [ ] C Compiler information (e.g. gcc 7.3): 
- [ ] Please reproduce the problem with debug tracing enabled and attach the resulting output as a gist
  * If the problem happens in a Pungi invocation, you can turn on tracing by setting `PUNGI_DEBUG=1`, e.g. `env PUNGI_DEBUG=1 pungi install -v 3.6.4`
    * If the problem is with `pungi install`, make sure to also enable its verbose mode (`-v`)
  * If the problem happens outside of a Pungi invocation, enable shell trace output like this:
     ```sh
     export PS4='+(${(%):-%x}:${LINENO}): ${funcstack[0]:+${funcstack[0]}(): }'  #Zsh
     export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'  #Bash
     set -x
     <reproduce the problem>
     set +x
     ```
