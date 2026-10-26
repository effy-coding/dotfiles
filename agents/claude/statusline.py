import json,sys,pathlib,os,tempfile,time
try:
 d=json.load(sys.stdin);p=pathlib.Path.home()/'Library/Application Support/AgentMonitor';p.mkdir(parents=True,exist_ok=True)
 if d.get('rate_limits'):
  fd,name=tempfile.mkstemp(dir=p)
  with os.fdopen(fd,'w') as f:json.dump({'limits':d['rate_limits'],'updatedAt':time.time()},f)
  os.replace(name,p/'account.json')
 print(d.get('model',{}).get('display_name','Claude'),end='')
except Exception:pass
