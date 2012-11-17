def calc_min_max_min_for(path,morning)
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