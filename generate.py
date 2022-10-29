import os
import glob
import json
import shutil

tpl = "PDPatcher.tpl"

with open("data.json") as fo:
    data = json.load(fo)

if os.path.exists("release"):
    shutil.rmtree("release")
os.mkdir("release")

for vars in data:
    ver = f"{vars['version']}-{vars['build']}"
    shutil.copytree(tpl, f"release/{ver}")
    for fpath in glob.glob(f"release/{ver}/**/*", recursive=True):
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
    os.system(f'pkgbuild --nopayload --scripts release/{ver}/scripts --identifier pd.patcher --version "{vars["version"]}" release/PDPatcher_{ver}.pkg')
    shutil.rmtree(f"release/{ver}")
os.system('hdiutil create -fs HFS+ -srcfolder "release" -volname "PD-Patcher" "release/release.dmg"')
