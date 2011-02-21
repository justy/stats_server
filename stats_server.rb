require 'sinatra'
require 'sinatra/reloader' if development?

# proof of concept with a static file
get '/demo' do

  #dir = params[:dir]
  # Move this into a model?

  # Grab the last rendered stats page
  stats = File.open("data/stats.txt", "r").read
  @data = Array.new
  lines = stats.split("\n")

  #puts lines[0]

  lines.each do |line|

    words = line.split(" ")
    #puts words[0]
    @data << (words[0] + ",") if !words[0].nil?

  end

  labels = File.open("data/labels.txt", "r").read
  @labels = Array.new
  labelz = labels.split("\n")
  labelz.each do |label|
    words = label.split(" ")
    @labels << ("\"" + words[1].gsub("'","\\\'") + "\",") if !words[1].nil?
  end

  erb :stats_server

end


# parametrised
get '/' do

  puts params[:stat_type]

  stat_type = params[:stat_type]
  stat_type = "top" if stat_type.nil?

  sort_key = params[:sort_key]
  sort_key = "cpu" if sort_key.nil?

  @target_dir = params[:target_dir]
  @target_dir = "~/fun" if @target_dir.nil?

  #puts "Target dir:" + @target_dir
  #@target_dir = "'" + @target_dir + "'"
  #puts "Target dir:" + @target_dir

  if stat_type == "top"

    puts "Rendering Stat Type: " + stat_type + " with sort key: " + sort_key

    if sort_key == "cpu"
      stats = `top -l 1 -o cpu`
      #Strip the first 13 lines
      new_stats = ""
      tops = stats.split("\n")
      tops.count.times do |i|
        if i > 12
          new_stats << tops[i] + "\n"
        end
      end
      #puts new_stats
      @data = arrayOfData(2,new_stats)
      @labels = arrayOfLabels(1,new_stats)
      #@links = arrayOfLinks(@labels,"?stat_type=top&sort_key=cpu")
      #erb :stats_server
    end

  end

  if stat_type == "du"

    puts "Rendering Stat Type: " + stat_type

    stats = `du -d 1 #{@target_dir}`
    #puts "Result"
    #puts `echo $?`
    @data = arrayOfData(0,stats)
    @data.delete_at(@data.count-1)
    @labels = arrayOfLabels(1,stats)
    #puts "There are " + @labels.count.to_s + " labels"
    @links = arrayOfLinks(@labels,"?stat_type=du")

    #erb :stats_server

  end

  if stat_type == "df"

    stats = `df`
    # Strip the first line
    new_stats = ""
    frees = stats.split("\n")
    frees.count.times do |i|
      if i > 0
        new_stats << frees[i] + "\n"
      end
    end
    #puts "Result"
    #puts `echo $?`
    @data = arrayOfData(3,new_stats)
    @labels = arrayOfLabels(0,new_stats)
    puts "There are " + @labels.count.to_s + " labels"
    #erb :stats_server
  end

  erb :stats_server

end


def arrayOfData column, raw_text
  #puts column
  #puts raw_text

  tmp = Array.new
  lines = raw_text.split("\n")
  puts "arrayOfData: There are " + lines.count.to_s + " data"
  lines.each do |line|
    #puts line
    words = line.split(" ")
    #puts words
    puts words[column]
    tmp << (words[column] + ",") if !words[column].nil?
  end

  tmp
end


def arrayOfLabels column, raw_text

  tmp = Array.new
  lines = raw_text.split("\n")

  lines.each do |line|
    #puts line
    words = line.split(" ") #.delete_at(1)
    words.delete_at(0)
    #puts words
    #puts words[column]
    labl = words.join(" ")
    #tmp << "\"" + (words[column].gsub("'","\\\'") + "\",")  if !words[column].nil?
    #tmp << "\"" + (labl.gsub("'","\\\'") + "\",")  if !words[column].nil?
    tmp << "\"" + labl.gsub("'","\\\'") + "\","
  end

  tmp
end


def arrayOfLinks array_of_paths, params

  #puts array_of_paths
  tmp = Array.new

  #puts "Count: " +  array_of_paths.count.to_s
  array_of_paths.each do |path|

    puts path

    this_link = "\"http://localhost:4567" + params + "&target_dir=" + path.gsub("\"","").gsub(",","").gsub(" ","%20") + "\","
    tmp << this_link

  end

  tmp
end