hs.hotkey.bind({"cmd"}, "q", function()
  hs.eventtap.keyStroke({}, "/")
end)

hs.hotkey.bind({"cmd"}, "w", function()
  hs.eventtap.keyStroke({"shift"}, "/")
end)
