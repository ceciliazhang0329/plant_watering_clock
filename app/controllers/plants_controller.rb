class PlantsController < ApplicationController
  def update_care_information(care_info)
    sentences = care_info.split('. ').map(&:strip)

    # extract integer from watering frequency sentence
    watering_freq_sentence = sentences[0]
    watering_freq_integer = watering_freq_sentence.scan(/\d+/).first.to_i
    self.watering_frequency = watering_freq_integer

    self.sunlight_requirements = sentences[1]   # extract sunlight requirements
    self.soil_type = sentences[2]               # extract soil type
    self.other_tips = sentences[3]              # extract other tips

    self.save
  end

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
    the_plant = Plant.new
    the_plant.user_id = current_user.id
    the_plant.plant_name = params.fetch("query_plant_name")
    the_plant.last_watered_date = params.fetch("query_last_watered_date")
    #the_plant.watering_frequency = params.fetch("query_watering_frequency")
    #the_plant.sunlight_requirement = params.fetch("query_sunlight_requirement")
    #the_plant.soil_type = params.fetch("query_soil_type")
    #the_plant.other_tips = params.fetch("query_other_tips")

    if the_plant.valid?
      the_plant.save
  
      # fetch plant care information from ChatGPT
      chat_gpt_service = ChatGPTService.new
      response = chat_gpt_service.query_plant_info(the_plant.plant_name)
      if response.success?
        plant_info = JSON.parse(response.body)
        care_info = plant_info['choices'].first['text']
        the_plant.update_care_information(care_info) # update plant watering_fre, sunlight_req, soil_type, and other_tips
      end

      redirect_to("/plants", { :notice => "Plant created successfully." })
    else
      redirect_to("/plants", { :alert => the_plant.errors.full_messages.to_sentence })
    end
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
