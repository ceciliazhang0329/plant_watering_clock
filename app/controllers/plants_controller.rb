class PlantsController < ApplicationController
  def index
    matching_plants = Plant.all

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
    the_plant.user_id = params.fetch("query_user_id")
    the_plant.plant_name = params.fetch("query_plant_name")
    the_plant.last_watered_date = params.fetch("query_last_watered_date")
    the_plant.watering_frequency = params.fetch("query_watering_frequency")
    the_plant.sunlight_requirement = params.fetch("query_sunlight_requirement")
    the_plant.soil_type = params.fetch("query_soil_type")
    the_plant.other_tips = params.fetch("query_other_tips")

    if the_plant.valid?
      the_plant.save
      redirect_to("/plants", { :notice => "Plant created successfully." })
    else
      redirect_to("/plants", { :alert => the_plant.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_plant = Plant.where({ :id => the_id }).at(0)

    the_plant.user_id = params.fetch("query_user_id")
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
