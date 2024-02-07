local dap = require("dap")

dap.adapters["node"] = {
  type = "server",
  host = "localhost",
  port = 8123,
  executable =  {
    command = "js-debug-adapter",
  }
}

for _, language in ipairs { "typescript", "javascript" } do
  dap.configurations[language] = {
    {
      type =  "node",
      request = "attach",
      name = "Docker: Attach to Node",
      port = 9229,
      address = "localhost",
      localRoot = "${workspaceFolder}",
      remoteRoot = "/app",
    }
  }
end
