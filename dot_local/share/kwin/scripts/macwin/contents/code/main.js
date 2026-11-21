const spaces = {};

function enter(w) {
    const id = w.internalId.toString();
    if (id in spaces || w.onAllDesktops) return;
    const idx = workspace.desktops.indexOf(workspace.currentDesktop) + 1;
    workspace.createDesktop(idx, w.caption);
    const desktop = workspace.desktops[idx];
    spaces[id] = { origin: w.desktops, desktop: desktop };
    w.desktops = [desktop];
    workspace.currentDesktop = desktop;
}

function exit(w, closing) {
    const id = w.internalId.toString();
    const s = spaces[id];
    if (!s) return;
    delete spaces[id];
    let origin = s.origin.filter(d => workspace.desktops.includes(d));
    if (!origin.length) origin = [workspace.desktops[0]];
    if (!closing) w.desktops = origin;
    if (workspace.currentDesktop === s.desktop) workspace.currentDesktop = origin[0];
    workspace.removeDesktop(s.desktop);
    if (!closing) workspace.activeWindow = w;
}

function track(w) {
    if (!w.normalWindow) return;
    w.fullScreenChanged.connect(() => w.fullScreen ? enter(w) : exit(w, false));
    w.closed.connect(() => exit(w, true));
}

workspace.windowList().forEach(track);
workspace.windowAdded.connect(track);

registerShortcut("macwinFullscreen", "macwin: Toggle Fullscreen on New Desktop", "Meta+Ctrl+F", () => {
    const w = workspace.activeWindow;
    if (w && w.fullScreenable) w.fullScreen = !w.fullScreen;
});

registerShortcut("macwinAlmostMaximize", "macwin: Almost Maximize", "Meta+Ctrl+Return", () => {
    const w = workspace.activeWindow;
    if (!w || w.fullScreen || !w.moveable || !w.resizeable) return;
    const a = workspace.clientArea(KWin.MaximizeArea, w);
    const width = Math.round(a.width * 0.9);
    const height = Math.round(a.height * 0.9);
    w.setMaximize(false, false);
    w.frameGeometry = {
        x: a.x + Math.round((a.width - width) / 2),
        y: a.y + Math.round((a.height - height) / 2),
        width: width,
        height: height,
    };
});
