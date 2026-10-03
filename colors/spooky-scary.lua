for name in pairs(package.loaded) do
  if name:match("^spooky%-scary") then
    package.loaded[name] = nil
  end
end
require("spooky-scary").load()
