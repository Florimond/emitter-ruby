require_relative "emitter"
require "tk"

emitter = Emitter.new({})#{"host"=>"api.emitter.io", "port"=>"8080"})

root = TkRoot.new do
  title("Emitter Ruby sample")
  minsize(600, 600)
end

text = TkText.new(root) do
   width(72)
   height(18)
   pack("side" => "bottom", "pady" => [0, 10])
end

emitter_key = TkVariable.new("QgvIV_kVciY2Q6KmuREjNasqD8vO98pM", :string)
TkLabel.new(root) do
   text("Key")
   pack("pady" => [10, 0])
end
TkEntry.new(root, "width" => 50, "textvariable" => emitter_key).pack()

channel = TkVariable.new("ruby", :string)
TkLabel.new(root) do
   text("Channel")
   pack("pady" => [10, 0])
end
TkEntry.new(root, "width" => 50, "textvariable" => channel).pack()

TkButton.new(root, "width" => 50) do
  text("Connect")
  command proc { emitter.connect() }
  pack("pady" => [10, 0])
end
TkButton.new(root, "width" => 50) do
  text("Subscribe")
  command proc { emitter.subscribe(emitter_key.value, channel.value) }
  pack()
end
TkButton.new(root, "width" => 50) do
  text("Presence")
  command proc { emitter.presence(emitter_key.value, channel.value) }
  pack()
end
TkButton.new(root, "width" => 50) do
  text("Publish")
  command proc { emitter.publish(emitter_key.value, channel.value, "Test message") }
  pack()
end
TkButton.new(root, "width" => 50) do
  text("Unsubscribe")
  command proc { emitter.unsubscribe(emitter_key.value, channel.value) }
  pack()
end
TkButton.new(root, "width" => 50) do
  text("Disconnect")
  command proc {
      emitter.disconnect()
      puts "Disconnect"
      text.insert(1.0, "Disconnect\n")
    }
  pack()
end

emitter.on_message do |message|
  puts "Message recieved on topic: #{message.topic}\n>>> #{message.payload}"
  text.insert(1.0, "Message received on topic: #{message.topic}\n>>> #{message.payload}\n")
end
emitter.on_presence do |message|
  puts "Presence message received on topic: #{message.topic}\n>>> #{message.payload}"
  text.insert(1.0, "Presence message received on topic: #{message.topic}\n>>> #{message.payload}\n")
end
emitter.on_connect do
  puts "Connected"
  text.insert(1.0, "Connected\n")
end
emitter.on_subscribe do
  puts "Subscribed"
  text.insert(1.0, "Subscribed\n")
end
emitter.on_unsubscribe do
  puts "unsubscribed"
  text.insert(1.0, "unsubscribed\n")
end

Tk.mainloop()
