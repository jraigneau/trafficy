#calcule min,max et mean pour un chemin selon si soir / matin
def calc_min_max_mean_for(path,morning)
  min = 100000
  max = 0
  mean = 0
  nb = 0
  Result.where(:path_id => path.id, :is_morning => morning).each do |result|
    minutes = result.minutes
    mean = mean + minutes
    if min>minutes then min = minutes end
    if max<minutes then max = minutes end
    nb = nb + 1
  end
  if nb != 0
    mean = mean/nb
  else #aucun calcul encore
    mean,min,max = "NA","NA","NA"
  end
  return min, max,mean 
end

#calcule le min, max, mean par chemin et par intervalle de temps
def stats_by_path_and_interval(path_id,interval)
  min = 100000
  max = 0
  mean = 0
  nb = 0  
  Result.where(:path_id => path_id, :interval => interval).each do |result|
    minutes = result.minutes
    mean = mean + minutes
    if min>minutes then min = minutes end
    if max<minutes then max = minutes end
    nb = nb + 1  
  end
  if nb != 0
    mean = mean/nb
  else #aucun calcul encore
    mean,min,max = "NA","NA","NA"
  end
  return min, max,mean 
end

TIME_SCATTER = [20,30,45,60,80,99999]

#calcule la répartition des temps par chemin et par intervalle de temps
def scatter_by_path_and_interval(path_id,interval)
  data = {}
  TIME_SCATTER.each do |time|
     data["#{time}"] = 0
  end
  minutesList = []
  Result.where(:path_id => path_id, :interval => interval).each do |result|
    minutes = result.minutes
    minutesList << minutes
    for i in 0..TIME_SCATTER.length-1
      if i>0 && i<TIME_SCATTER.length-1
        if minutes > TIME_SCATTER[i-1] && minutes <= TIME_SCATTER[i]
          data["#{TIME_SCATTER[i]}"] = data["#{TIME_SCATTER[i]}"] + 1
          break
        end
      elsif i == 0
        if minutes <= TIME_SCATTER[i]
          data["#{TIME_SCATTER[i]}"] = data["#{TIME_SCATTER[i]}"] + 1
          break
        end
      else
        if minutes > TIME_SCATTER[i-1]
          data["#{TIME_SCATTER[i]}"] = data["#{TIME_SCATTER[i]}"] + 1
          break
        end
      end
    end
  end
  return data
end

#Prepare les données pour le graph en bar
def calc_chart_bar(path_id,hours)
  data,xAxis = [],[]
  max_interval = hours.max*100+45
  for i in hours
    for j in [0,15,30,45]
      interval = i*100+j
      if interval > max_interval #pas d'horaire supérieur à max_interval
        break
      end
      min,max,mean = stats_by_path_and_interval(path_id,interval)
      if min != "NA"
        data << [min,max]
        if j == 0 
          xAxis << ["#{i}:#{j}0"]
        else
          xAxis << ["#{i}:#{j}"]
        end
      end
    end
  end
  return data,xAxis
end

#Prepare les données pour le graph en répartition par %
def calc_chart_scatter(path_id,hours)
  scatterData = {}
  TIME_SCATTER.each do |time|
     scatterData["#{time}"] = []
  end
  
  data,xAxis = [],[]
  max_interval = hours.max*100+45
  for i in hours
    for j in [0,15,30,45]
      interval = i*100+j
      if interval > max_interval #pas d'horaire supérieur à max_interval
        break
      end
      data = scatter_by_path_and_interval(path_id, interval)
      if data.length != 0
        if j == 0 
          xAxis << ["#{i}:#{j}0"]
        else
          xAxis << ["#{i}:#{j}"]
        end
        TIME_SCATTER.each do |time|
           scatterData["#{time}"] << data["#{time}"]
        end
      end
    end
  end
  return scatterData,xAxis
end