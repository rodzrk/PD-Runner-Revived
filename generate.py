import os
import glob
import json
import shutil

app = "PDPatcher.app"
tpl = "PDPatcher.app.tpl"

with open("data.json") as fo:
    data = json.load(fo)

if os.path.exists("release"):
    shutil.rmtree("release")
os.mkdir("release")

for vars in data:
    dirname = f"{vars['version']}-{vars['build']}"
    os.mkdir(f"release/{dirname}")
    shutil.copytree(tpl, f"release/{dirname}/{app}")
    for fpath in glob.glob(f"release/{dirname}/{app}/**/*", recursive=True):
        if not os.path.isfile(fpath):
            continue
        print(fpath)
        with open(fpath, "rb+") as fo:
            content = fo.read()
            for k, v in vars.items():
                content = content.replace(b"{{%s}}" % k.encode("ascii"), str(v).encode("ascii"))
            fo.seek(0)
            fo.truncate(0)
            fo.write(content)
