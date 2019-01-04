require_relative "emitter"
require "tk"

emitter = Emitter.new()

root = TkRoot.new do
  title("Emitter Ruby sample")
  minsize(450, 450)
end

text = TkText.new(root) do
   width(50)
   height(10)
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
  text.insert(1.0, "Message recieved on topic: #{message.topic}\n>>> #{message.payload}\n")
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

exit

key = "QgvIV_kVciY2Q6KmuREjNasqD8vO98pM"
channel = "ruby"
emitter = Emitter.new()
emitter.on_message do |message|
  puts "Message recieved on topic: #{message.topic}\n>>> #{message.payload}"
  #message_counter += 1
  emitter.unsubscribe(key, channel)
end

emitter.on_connect do
  puts "Connected"
  emitter.subscribe(key, channel)

end

emitter.connect()

waiting_suback = true
emitter.on_subscribe do
  puts "Emitter subscribed"
  waiting_suback = false
  emitter.publish(key, channel, "test")
end

#while waiting_suback do
#  sleep 0.01
#end

#puts(emitter.format_channel("key", "value", {ttl: 12, last: 5}))

while true do
  puts(".")
  sleep 1
end
#emitter.connect_handler.to_proc.call()
#emitter.on_message.call()

exit


### Create a simple client with default attributes
client = PahoMqtt::Client.new

### Register a callback on message event to display messages
message_counter = 0
client.on_message do |message|
  puts "Message recieved on topic: #{message.topic}\n>>> #{message.payload}"
  message_counter += 1
end

### Register a callback on suback to assert the subcription
waiting_suback = true
client.on_suback do
  waiting_suback = false
  puts "Subscribed"
end

### Register a callback for puback event when receiving a puback
waiting_puback = true
client.on_puback do
  waiting_puback = false
  puts "Message Acknowledged"
end

### Connect to the eclipse test server on port 1883 (Unencrypted mode)
client.connect 'iot.eclipse.org', 1883

### Subscribe to a topic
client.subscribe ['/paho/ruby/test', 2]

### Waiting for the suback answer and excute the previously set on_suback callback
while waiting_suback do
  sleep 0.001
end

### Publlish a message on the topic "/paho/ruby/test" with "retain == false" and "qos == 1"
client.publish "/paho/ruby/test", "Hello there!", false, 1

while waiting_puback do
  sleep 0.001
end

### Waiting to assert that the message is displayed by on_message callback
sleep 1

### Calling an explicit disconnect
client.disconnect
