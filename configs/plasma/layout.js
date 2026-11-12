var ps = panels();
var top = panelById(2);
if (!top) throw new Error('No se encontró el panel original');
var managed = ps.filter(function(p){p.currentConfigGroup=['General']; return String(p.readConfig('KessokuManaged',false)) === 'true';});
if (managed.length > 1) throw new Error('Hay varios docks Kessoku; no se modificaron.');
var dock = managed.length ? managed[0] : null;
if (dock && (dock.location != 'bottom' || dock.widgets('org.kde.plasma.icontasks').length != 1)) throw new Error('El dock Kessoku fue modificado; no se cambió.');
top.location = 'top';
top.height = 44;
top.floating = true;
top.hiding = 'none';
if (!top.widgets().some(function(w){return w.type === 'org.kde.plasma.panelspacer';})) top.addWidget('org.kde.plasma.panelspacer',85,10,20,20);
var oldTasks = top.widgets();
for (var t=0;t<oldTasks.length;t++) if (oldTasks[t].id === 5 && oldTasks[t].type === 'org.kde.plasma.icontasks') oldTasks[t].remove();
// Retirar únicamente las instancias añadidas por Kessoku al panel.
[30,31,32,37].forEach(function(id){var w=top.widgetById(id); if(w && ['org.kde.plasma.mediacontroller','org.kde.plasma.systemmonitor.cpu','org.kde.plasma.systemmonitor.memory','org.kde.plasma.systemmonitor.net'].indexOf(w.type)>=0)w.remove();});
if (!dock) {
  dock = new Panel;
  dock.location = 'bottom';
  dock.currentConfigGroup=['General']; dock.writeConfig('KessokuManaged',true);
  var tasks = dock.addWidget('org.kde.plasma.icontasks');
  tasks.currentConfigGroup = ['General'];
  tasks.writeConfig('launchers', ['applications:org.kde.dolphin.desktop','applications:org.kde.konsole.desktop','preferred://browser','applications:com.microsoft.VSCode.desktop','applications:steam.desktop','applications:spotify.desktop']);
}
var desktop = desktops()[0];
if (!desktop.widgets('org.kde.plasma.digitalclock').length) {
  var clock = desktop.addWidget('org.kde.plasma.digitalclock',72,160,300,112);
  clock.currentConfigGroup=['Appearance']; clock.writeConfig('showDate',true); clock.writeConfig('dateFormat','custom'); clock.writeConfig('customDateFormat','ddd · d MMM yyyy · 音楽');
}
if (!desktop.widgets('org.kde.plasma.mediacontroller').length) desktop.addWidget('org.kde.plasma.mediacontroller',72,310,340,220);
desktop.widgets('org.kde.plasma.systemmonitor.net').forEach(function(w){w.remove();});
['org.kde.plasma.systemmonitor.cpu','org.kde.plasma.systemmonitor.memory'].forEach(function(type,i){if(!desktop.widgets(type).length)desktop.addWidget(type,88+i*180,770,165,100);});
dock.height = 64;
dock.floating = true;
dock.alignment = 'center';
dock.lengthMode = 'fit';
dock.hiding = 'dodgewindows';
print(JSON.stringify(panels().map(function(p){return {id:p.id,location:p.location,floating:p.floating,opacity:p.opacity,hiding:p.hiding,lengthMode:p.lengthMode,widgets:p.widgets().map(function(w){return w.type})}})));
