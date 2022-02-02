If you are reporting a bug, please make sure to include the following information:
- [ ] Platform information (e.g. Ubuntu 20.04):
- [ ] CPU architecture (e.g. amd64):
- [ ] pungi version:
- [ ] Python version:
- [ ] C Compiler information (e.g. gcc 7.3): 
- [ ] Please attach the debug trace of the failing command as a gist:
  * Run `env PUNGI_DEBUG=1 <faulty command> 2>&1 | tee trace.log` and attach `trace.log`. E.g. if you have a problem with installing Python, run `env PUNGI_DEBUG=1 pungi install -v <version> 2>&1 | tee trace.log` (note the `-v` option to `pungi install`).
