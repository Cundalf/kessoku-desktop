#!/usr/bin/env python3
"""Regenerar las paletas desde Kessoku Comfort; no modifica la sesión."""
import configparser,json
from pathlib import Path
root=Path(__file__).resolve().parent
specs={
'yui':('Yui Hirasawa','e8a096','4c3d43'),
'mio':('Mio Akiyama','9ab8df','35445b'),
'ritsu':('Ritsu Tainaka','dfbb82','494337'),
'tsumugi':('Tsumugi Kotobuki','bfb0e4','454057'),
'bocchi':('Hitori Gotoh · Bocchi','e8acd1','4b3c50'),
'nijika':('Nijika Ijichi','e2c780','494332'),
'ryo':('Ryo Yamada','8fb9d3','344650'),
'kita':('Ikuyo Kita','e59a9d','4d3b42'),
'kikuri':('Kikuri Hiroi','d49abf','4a3b50'),
}
def rgb(h): return ','.join(str(int(h[i:i+2],16)) for i in (0,2,4))
catalog={}
for key,(name,accent,selection) in specs.items():
    dest=root/key;dest.mkdir(exist_ok=True)
    scheme='Kessoku'+key.capitalize()
    c=configparser.ConfigParser(interpolation=None);c.optionxform=str
    c.read(root.parent/'configs/colors/KessokuComfort.colors')
    c['General']['Name']='Kessoku · '+name;c['General']['ColorScheme']=scheme
    for section in c.sections():
        if section.startswith('Colors:'):
            c[section]['DecorationFocus']=rgb(accent)
            c[section]['ForegroundActive']=rgb(accent)
    c['Colors:Selection']['BackgroundNormal']=rgb(selection)
    c['Colors:Selection']['BackgroundAlternate']=rgb(selection)
    c['Colors:Selection']['ForegroundActive']='238,240,247'
    with (dest/(scheme+'.colors')).open('w') as f:c.write(f,space_around_delimiters=False)
    catalog[key]={'name':name,'scheme':scheme,'accent':'#'+accent,'wallpaper':f'themes/{key}/wallpaper-4k.png'}
(root/'base').mkdir(exist_ok=True)
(root/'base/KessokuComfort.colors').write_bytes((root.parent/'configs/colors/KessokuComfort.colors').read_bytes())
catalog['base']={'name':'Kessoku original','scheme':'KessokuComfort','accent':'#a79bc2','wallpaper':'assets/wallpapers/kessoku-stage-4k.png'}
(root/'catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n')
