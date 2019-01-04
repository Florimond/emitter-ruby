require 'paho-mqtt'

class Emitter
  # For functions
  def on_connect=(callback)
    @mqtt.on_connack = callback
  end
  # For blocks
  def on_connect(&block)
    @mqtt.on_connack(&block)
    #@on_connect = block if block_given?
    #@on_connect #????
  end

  def on_subscribe=(callback)
    @mqtt.on_suback = callback
  end
  def on_subscribe(&block)
    @mqtt.on_suback(&block)
  end

  def on_unsubscribe=(callback)
    @mqtt.on_unsuback = callback
  end
  def on_unsubscribe(&block)
    @mqtt.on_unsuback(&block)
  end

  def on_message=(callback)
    #@mqtt.on_message = callback
    @on_message = callback
  end
  def on_message(&block)
    #@mqtt.on_message(&block)
    @on_message = block if block_given?
  end

  def on_presence=(callback)
    @on_presence = callback
  end
  def on_presence(&block)
    @on_presence = block if block_given?
  end


  def initialize()
    @mqtt = PahoMqtt::Client.new
    @mqtt.on_message do |message|
      @on_message.call(message)
    end
  end

  def connect()

    @mqtt.connect('api.emitter.io', 8080)
  end

  def disconnect()
    @mqtt.disconnect()
  end

  #private
  def format_channel(key, channel, options=nil)
    # Prefix with the key.
    formatted = key.end_with?("/") ? key + channel : key + "/" + channel
    # Add trailing slash.
    formatted = formatted + "/" if !formatted.end_with?("/")
    # Add options.
    formatted = formatted + "?" + options.map{|k,v| "#{k}=#{v}"}.join('&') if options #and options.keys.count > 0
    formatted
  end

  def publish(key, channel, message, ttl=nil)
    options = {}
    options[:ttl] = ttl if ttl != nil
    topic = self.format_channel(key, channel, options)
    #puts(topic)
    @mqtt.publish(topic, "Hello there!", false, 0)
  end

  def subscribe(key, channel, last=nil)
    options = {}
    options[:last] = last if last != nil
    topic = self.format_channel(key, channel, options)
    @mqtt.subscribe([topic, 0])
  end

  def unsubscribe(key, channel)
    topic = self.format_channel(key, channel)
    @mqtt.unsubscribe(topic)
  end
end
