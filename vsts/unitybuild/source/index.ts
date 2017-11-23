import path = require('path');
import fs = require('fs');
import tl = require('vsts-task-lib/task');
import trm = require('vsts-task-lib/toolrunner');

async function run() {
    try {
        tl.setResourcePath(path.join(__dirname, 'task.json'));

        // Read inputs
        let projectPath: string = tl.getPathInput('projectPath', true, true);

        let tool: trm.ToolRunner;
        let unityPath: string;

        let x86winPath = "C:\\Program Files (x86)\\Unity\\Editor\\Unity.exe";
        let x64winPath = "C:\\Program Files\\Unity\\Editor\\Unity.exe";
        let macOsPath = "/Applications/Unity/Unity.app/Contents/MacOS/Unity";

        if (fs.existsSync(x86winPath)) {
            unityPath = x86winPath;
        }
        if (fs.existsSync(x64winPath)) {
            unityPath = x64winPath;
        }
        if (fs.existsSync(macOsPath)) {
            unityPath = macOsPath;
        }

        tool = tl.tool(unityPath).arg('-batchmode').arg('-quit').arg('-nographics').arg('-projectPath').arg(projectPath);
        
        await addTargetsToArgList(tool);

        let rc1: number = await tool.exec();
    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

async function addTargetsToArgList(tool: trm.ToolRunner) {
    await addTargetToArgList(tool, "win32standalone", "-buildWindowsPlayer", "win32standaloneOutput");
    await addTargetToArgList(tool, "win64standalone", "-buildWindows64Player", "win64standaloneOutput");
    await addTargetToArgList(tool, "osx32standalone", "-buildOSXPlayer", "osx32standaloneOutput");
    await addTargetToArgList(tool, "osx64standalone", "-buildOSX64Player", "osx64standaloneOutput");
    await addTargetToArgList(tool, "osxUniversal", "-buildOSXUniversalPlayer", "osxUniversalOutput");
    await addTargetToArgList(tool, "linux32standalone", "-buildLinux32Player", "linux32standaloneOutput");
    await addTargetToArgList(tool, "linux64standalone", "-buildLinux64Player", "linux64standaloneOutput");
    await addTargetToArgList(tool, "linuxUniversal", "-buildLinuxUniversalPlayer", "linuxUniversalOutput");
}

async function addTargetToArgList(tool: trm.ToolRunner, platform: string, cmdArg: string, outputPath: string) {
    tool.argIf(tl.getBoolInput(platform), cmdArg);
    tool.argIf(tl.getBoolInput(platform), tl.getPathInput(outputPath, true));
}

run();