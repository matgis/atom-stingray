{CompositeDisposable} = require "atom"
Path = require "path"
FileSystem = require "fs"
WebSocket = require("websocket").w3cwebsocket

getViewUrl = (editorDataPath, moduleName, viewName) ->
  bootFilePath = Path.join(editorDataPath, "Core", "boot.html")
  viewFilePathWithoutExtension = Path.join(editorDataPath, "Modules", moduleName, "Views", viewName)
  bootFilePath.replace(/\\/g, "\/") + "?partial=" + viewFilePathWithoutExtension.replace(/\\/g, "\/")

createWebView = (editorDataPath, moduleName, viewName) ->
  element = document.createElement("webview")
  element.className = "stingray-" + viewName + " native-key-bindings"
  element.plugins = true
  element.disablewebsecurity = true
  element.preload = Path.join(__dirname, "node-shim.js")
  element.src = getViewUrl(editorDataPath, moduleName, viewName)

  element.addEventListener 'console-message', (e) ->
    unless element.isDevToolsOpened() then element.openDevTools()

  element

module.exports = Stingray =
  subscriptions: null
  logConsolePanel: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'stingray:test': => @test()

    request = new XMLHttpRequest()
    request.open("GET", "http://127.0.0.1:55503/v1/editor_data_path", true)
    request.onload = ->
      if request.status < 200 or request.status >= 400
        console.error("Unable to connect to Stingray Editor Backend")

      editorDataPath = JSON.parse(request.responseText)

      @statusBarPanel = atom.workspace.addBottomPanel {
        "item": createWebView(editorDataPath, "Stingray.StatusBar", "status-bar")
        "visible": true
        "priority": 0
      }

      @logConsolePanel = atom.workspace.addBottomPanel {
        "item": createWebView(editorDataPath, "Stingray.LogConsole", "log-console")
        "visible": true
        "priority": 1
      }

    request.send()

  deactivate: ->
    @logConsolePanel.destroy()
    @statusBarPanel.destroy()
    @subscriptions.dispose()
