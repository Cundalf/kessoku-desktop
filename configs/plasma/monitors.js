var d=desktops()[0];
['org.kde.plasma.systemmonitor.cpu','org.kde.plasma.systemmonitor.memory'].forEach(function(type,i){
 var w=d.widgets(type)[0]; if(!w)throw Error('Falta monitor '+type);
 w.userBackgroundHints='NoBackground';
 w.currentConfigGroup=['Appearance'];w.writeConfig('chartFace','org.kde.ksysguard.textonly');w.writeConfig('title',i?'RAM':'CPU');
 w.currentConfigGroup=['Sensors'];w.writeConfig('lowPrioritySensorIds','[]');w.writeConfig('totalSensors','[]');w.reloadConfig();
});
