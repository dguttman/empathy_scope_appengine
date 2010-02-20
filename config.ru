require 'appengine-rack'
require 'json'
require 'pp'
require 'java'

java_import java.lang.System
version = System.getProperties["java.runtime.version"]

# currentEmotionalState = Java::SynesketchEmotion::EmotionalState.new

class TweetEmotion
  import "synesketch"
  import "synesketch.emotion"

  def initialize(words)
    @words = words
    @state = Empathyscope.getInstance().feel(words)
  end

  def weights
    weights = {}
    emotions = %w(happiness sadness anger fear disgust surprise).map {|e| e.to_sym }
    emotions.each do |emotion|
      weight = @state.send("#{emotion}_weight")
      weights[emotion] = weight
      p "#{emotion}: #{weight}"
    end
    return weights
  end
end

def get_emotion_json(words)
  JSON.generate(TweetEmotion.new(words).weights)
end

AppEngine::Rack.configure_app(          
    :application => "empathyscope",           
    :precompilation_enabled => true,
    :version => "1")
    
run lambda { |env| 
  response = get_emotion_json(env["QUERY_STRING"].split("=")[1])

  status = 200
  content_type = {"Content-Type" => "text/plain"}
  [status, content_type, [ response ] ] 
}