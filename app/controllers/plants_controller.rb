class PlantsController < ApplicationController
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def index
    matching_plants = Plant.where(user_id: current_user.id) #users can only see the list of their plants

    @list_of_plants = matching_plants.order({ :created_at => :desc })

    render({ :template => "plants/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_plants = Plant.where({ :id => the_id })

    @the_plant = matching_plants.at(0)

    render({ :template => "plants/show" })
  end

  def create
    the_plant = Plant.new(plant_name: params[:query_plant_name], last_watered_date: params[:query_last_watered_date])
    the_plant.user_id = current_user.id
  
    if the_plant.save
      # Prepare the request data for OpenAI
      request_data = {
        'model' => 'gpt-3.5-turbo',
        'messages' => [
          { 'role' => 'system', 'content' => 'You are an expert at growing plants' },
          {
            'role' => 'user',
            'content' => "Could you provide the watering frequency, sunlight requirements, soil type, and other tips for growing a #{the_plant.plant_name}? 
  
            Here is the requirement for answering the question:
            1. Write each sentence for watering frequency, sunlight requirements, soil type, and other tips respectively. Include no other sentences in the answer (only 4 sentences).
            2. When answering watering frequency, the unit should be days. Answer it only in an integer. For example: 4"
          }
        ]
      }
  
      # Convert the request data to JSON
      request_json = request_data.to_json
  
      # Set up the HTTP request to OpenAI
      api_url = URI("https://api.openai.com/v1/chat/completions")
      request = Net::HTTP::Post.new(api_url)
      request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
      request['Content-Type'] = 'application/json'
      request.body = request_json
  
      # Send the request to OpenAI
      response = Net::HTTP.start(api_url.hostname, api_url.port, use_ssl: true) do |http|
        http.request(request)
      end
  
      # Parse the response JSON
      response_data = JSON.parse(response.body)
  
      # Extract the assistant's reply
      assistant_reply = response_data['choices'][0]['message']['content']
  
      # Update the plant care information
      update_plant_care_information(the_plant, assistant_reply) if assistant_reply.present?
  
      redirect_to plants_path, notice: 'Plant created successfully.'
    else
      render :new, alert: the_plant.errors.full_messages.to_sentence
    end
  end
  
  private
  
  def update_plant_care_information(plant, care_info)
    sentences = care_info.split('. ').map(&:strip)
    plant.update(
      watering_frequency: sentences[0].scan(/\d+/).first.to_i,
      sunlight_requirement: sentences[1],
      soil_type: sentences[2],
      other_tips: sentences[3]
    )
  end

  def update
    the_id = params.fetch("path_id")
    the_plant = Plant.where({ :id => the_id }).at(0)

    the_plant.user_id = current_user.id
    the_plant.plant_name = params.fetch("query_plant_name")
    the_plant.last_watered_date = params.fetch("query_last_watered_date")
    the_plant.watering_frequency = params.fetch("query_watering_frequency")
    the_plant.sunlight_requirement = params.fetch("query_sunlight_requirement")
    the_plant.soil_type = params.fetch("query_soil_type")
    the_plant.other_tips = params.fetch("query_other_tips")

    if the_plant.valid?
      the_plant.save
      redirect_to("/plants/#{the_plant.id}", { :notice => "Plant updated successfully."} )
    else
      redirect_to("/plants/#{the_plant.id}", { :alert => the_plant.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_plant = Plant.where({ :id => the_id }).at(0)

    the_plant.destroy

    redirect_to("/plants", { :notice => "Plant deleted successfully."} )
  end

  def show
    render({ :template => "plants/about" })
  end
end
