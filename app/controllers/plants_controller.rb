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
      care_info = fetch_plant_care_info(the_plant.plant_name)
      update_plant_care_information(the_plant, care_info) if care_info.present?

      redirect_to plants_path, notice: 'Plant created successfully.'
    else
      render :new, alert: the_plant.errors.full_messages.to_sentence
    end
  end

  def plant_params
    params.permit(:query_plant_name, :query_last_watered_date)
  end  

  def fetch_plant_care_info(plant_name)
    response = self.class.post(
      "/engines/gpt-3.5-turbo/completions",
      headers: {
        "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
        "Content-Type" => "application/json"
      },
      body: {
        prompt: "Suppose you are an expert at growing plants. Could you provide the watering frequency, sunlight requirements, soil type, and other tips for growing a #{plant_name}? Here is the requirement for answering the question: 1. Only reply 4 sentences for watering frequency, sunlight requirements, soil type, and other tips respectively. Include no other sentences in the answer. 2. When answering watering frequency, the unit should be days. Answer it only in an integer. For example: 4"
      }.to_json
    )

    if response.success?
      JSON.parse(response.body)['choices'].first['text']
    end
  end

  def update_plant_care_information(plant, care_info)
    sentences = care_info.split('. ').map(&:strip)
    plant.update(
      watering_frequency: sentences[0].scan(/\d+/).first.to_i,
      sunlight_requirements: sentences[1],
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
end
