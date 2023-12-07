class ChatGPTService
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def initialize
    @headers = {
      "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
      "Content-Type" => "application/json"
    }
  end

  def query_plant_info(plant_name)
    body = {
      prompt: "Suppose you are an expert at growing plants. Could you provide the watering frequency, sunlight requirements, soil type, and other tips for growing #{plant_name}? 

      Here is the requirement for answering the question:
      1. Only reply 4 sentences for watering frequency, sunlight requirements, soil type, and other tips respectively. Include no other sentences in the answer.
      2. When answering watering frequency, the unit should be days. Answer it only in an integer. For example: 4
      ",
      max_tokens: 150
    }.to_json

    self.class.post("/engines/gpt-4/completions", body: body, headers: @headers)
  end
end
