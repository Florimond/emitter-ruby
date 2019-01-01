require 'paho-mqtt'

class Emitter



  #@connect
  #attr_accessor :on_message

  # For functions
  def on_connect=(callback)
    #@on_connect = callback if callback.is_a?(Proc)
    @mqtt.on_connack = callback
  end
  # For blocks
  def on_connect(&block)
    @mqtt.on_connack(&block)
    #@on_connect = block if block_given?
    #@on_connect #????
  end

  def initialize()
    @mqtt = PahoMqtt::Client.new
    #@mqtt.on_connack do
    #  puts("connack")
    #end
  end

  def connect()
    @mqtt.connect 'iot.eclipse.org', 1883
  end

  def disconnect()
    @mqtt.disconnect()
  end
end


emitter = Emitter.new()
emitter.on_connect do
  puts "Emitter connected"
end
emitter.connect()

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
