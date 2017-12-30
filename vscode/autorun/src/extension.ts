'use strict';
import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    let path = vscode.workspace.rootPath + "\\";
    let config = require(path + "autorun.json");

    config.commands.forEach(element => {
        let term = vscode.window.createTerminal(element.label);
        term.show();
        term.sendText("cd " + path + element.workdir)
        term.sendText(element.command, true);
    });
}

export function deactivate() {
}