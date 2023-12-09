module PlantsHelper
  def overdue_plants_count(user)
    Plant.where(user: user)
          .where("
            (last_watered_date IS NOT NULL) AND
            (watering_frequency IS NOT NULL) AND
            (date(last_watered_date, '+' || watering_frequency || ' days') < date('now'))
          ").count
  end

  def today_water_plants_count(user)
    Plant.where(user: user)
          .where("
            (last_watered_date IS NOT NULL) AND
            (watering_frequency IS NOT NULL) AND
            (date(last_watered_date, '+' || watering_frequency || ' days') = date('now'))
          ").count
  end

  def no_need_for_water_plants_count(user)
    Plant.where(user: user)
          .where("
            (last_watered_date IS NOT NULL) AND
            (watering_frequency IS NOT NULL) AND
            (date(last_watered_date, '+' || watering_frequency || ' days') > date('now'))
          ").count
  end
end
