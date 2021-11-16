If you are reporting a bug, please make sure to include the following information:
- [ ] Platform information (e.g. Ubuntu 20.04):
- [ ] CPU architecture (e.g. amd64):
- [ ] pungi version:
- [ ] Python version:
- [ ] C Compiler information (e.g. gcc 7.3): 
- [ ] Please attach a debug trace log as gist
  * If the problem happens in a Pungi invocation, you can turn on debug logging by setting `PUNGI_DEBUG=1`, e.g. `env PUNGI_DEBUG=1 pungi install -v 3.6.4`
  * If the problem happens outside of a Pungi invocation, get the debug log like this:
     ```
     export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
     set -x
     <reproduce the problem>
     set +x
     ```
