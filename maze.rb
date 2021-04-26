

#!/usr/local/bin/ruby

# ########################################
# CMSC 330 - Project 1
# ########################################

#-----------------------------------------------------------
# FUNCTION DECLARATIONS
#-----------------------------------------------------------

def parse(file)
end



def open_command(file)
read_and_print_simple_file(file, "open")

end

def bridge(file)
read_and_print_simple_file(file, "bridge")
end

def sortcells(file)
read_and_print_simple_file(file, "sortcells")
end

def paths(file)
read_and_print_simple_file(file, "paths")
end

def print(file)
read_and_print_simple_file(file, "print")
end

def distance(file)
read_and_print_simple_file(file, "distance")
end

def solve(file)
  read_and_print_simple_file(file, "solve")
end
#-----------------------------------------------------------
# the following is a parser that reads in a simpler version
# of the maze files.  Use it to get started writing the rest
# of the assignment.  You can feel free to move or modify 
# this function however you like in working on your assignment.

def read_and_print_simple_file(file, type)
line = file.gets
if line == nil then return end
first_cell = 0
first_path = 0
open_counter = 0
bridge_counter = 0
sort_zero = "0"
sort_one = "1"
sort_two = "2"
sort_three = "3"
sort_four = "4"
sort_final = ""
header = []
shortest_path = ""
match_start = 0
match_end = 0
# read 1st line, must be maze header
sz, sx, sy, ex, ey = line.split(/\s/)
header[0] = sz #size
header[1] = sx #starting x
header[2] = sy #starting y
header[3] = ex #ending x
header[4] = ey #ending y
start_coord = "#{header[1]},#{header[2]}" # store starting coord for maze
end_coord = "#{header[3]},#{header[4]}" # store ending coord for maze
  # read additional lines
while line = file.gets do
  # begins with "path", must be path specification
  if line[0...4] == "path"
    p, name, x, y, ds = line.split(/\s/)
    if first_path == 0 then
      pathx_hash = {name => "#{x}"} # store the x of path
      pathy_hash = {name => "#{y}"} # store the y of path
      pathdir_hash = {name => "#{ds}"} # store directions of the path
      first_path += 1
    else
      pathdir_hash[name] = "#{ds}"
      pathx_hash[name] = "#{x}"
      pathy_hash[name] = "#{y}"
    end
    # otherwise must be cell specification (since maze spec must be valid)
  else
    x, y, ds, w = line.split(/\s/,4)
    if w != nil
      ws = w.split(/\s/)
    end
    
    if first_cell == 0 then
      direction_hash = { "#{x},#{y}" => "#{ds}"} # map specific coords to their directions
      weight_hash = { "#{x},#{y}" => "#{ws}"} # map specific coords to their weights
      first_cell += 1
    else
      direction_hash["#{x},#{y}"] = "#{ds}"
      weight_hash["#{x},#{y}"] = "#{ws}"
    end
  end
end

if type == "open"
  direction_hash.each do |coord, direction| # go through each coord and check their directions to see if the cell is open
    if coord[0].include? "0" or coord[0].include? (header[0].to_i-1).to_s or coord[2].include? "0" or coord[2].include? (header[0].to_i-1).to_s # makes sure the cell is not around the edges because they don't have 4 open paths
      next
    end
    if direction_hash[coord].length == 4 # if the direction has all the 4 letters, it is open
      open_counter = open_counter + 1
    end
  end
  return open_counter
end
if type == "bridge"
  #check for vertical bridges
  for x in 0..header[0].to_i-1 do
    for y in 0..header[0].to_i-1 do
      #check to make sure the next two cells are valid to create a bridge
      if (y+1) <= header[0].to_i-1 and (y+2) <= header[0].to_i-1 and direction_hash["#{x},#{y}"].include? "d" and direction_hash["#{x},#{y+1}"].include? "u" and direction_hash["#{x},#{y+2}"].include? "u" and direction_hash["#{x},#{y+1}"].include? "d"
        bridge_counter = bridge_counter + 1
      else
        next
      end
    end
  end
  #check for horizontal bridges
  for y in 0..header[0].to_i-1 do
    for x in 0..header[0].to_i-1 do
      if (x+1) <= header[0].to_i-1 and (x+2) <= header[0].to_i-1 and direction_hash["#{x},#{y}"].include? "r" and direction_hash["#{x+1},#{y}"].include? "l" and direction_hash["#{x+2},#{y}"].include? "l" and direction_hash["#{x+1},#{y}"].include? "r"
        bridge_counter = bridge_counter + 1
      else
        next
      end
    end
  end

  return bridge_counter
end
  if type == "sortcells"
  direction_hash.each do |coord, direction| # check each coord to see if they have either 0, 1, 2, 3, or 4 openings
    if direction_hash[coord].length == 4
      sort_four = sort_four + ",(" + coord + ")"
    elsif direction_hash[coord].length == 3
      sort_three = sort_three + ",(" + coord + ")"
    elsif direction_hash[coord].length == 2
      sort_two = sort_two + ",(" + coord + ")"
    elsif direction_hash[coord].length == 1
      sort_one = sort_one + ",(" + coord + ")"
    else
      sort_zero = sort_zero + ",(" + coord + ")"
    end
  end
  
  arr = []
  to_array = ""
  arr[0] = sort_zero
  arr[1] = sort_one
  arr[2] = sort_two
  arr[3] = sort_three
  arr[4] = sort_four
  for i in 0..4
    if arr[i].length > 1
      to_array = to_array + arr[i] # converts the string to array
    end
    to_array = to_array + "\n"  
  end
  to_array = to_array.chomp #removes unecessary \n
  array = to_array.split
  return array 
end
  if type == "paths" or type == "print" # print method uses some information gained from doing the paths method
  result = []
  skip = 0
  hash = {}
  if pathdir_hash == nil # no path present 
    if type == "paths"    
      return "none"
    else
      shortest_path = "none"
      skip = 1 
    end
  end
  if skip == 0
    if pathdir_hash != nil
      path_amount = pathdir_hash.keys.length - 1
    end
    for i in 0..path_amount do # go through each path
      path_arr = []
      weight_sum = 0
      valid = 1
      check = 0
      path_name = pathdir_hash.keys[i]
      x = pathx_hash[path_name]
      y = pathy_hash[path_name]
      path_direction = pathdir_hash[path_name]
      if path_direction != nil
        path_length = path_direction.length-1
      end
      path_arr << "#{x},#{y}"
      for j in 0..path_length do # go through each direction of said path
        direction = direction_hash["#{x},#{y}"] # gain what directions a cell can go through
        weight = weight_hash["#{x},#{y}"] # and their weight
          if direction.include? path_direction[j] # if the cell is on the path, continue 
            direction_index = direction.index(path_direction[j])
            check = 1
            convert = weight.delete "["
            convert = convert.delete "]" # getting the weight into a variable
            if convert != nil
              weight_array = convert.split(",")
              actual_weight = weight_array[direction_index].delete " \" "
              actual_weight = actual_weight.to_f
              weight_sum += actual_weight
            end
              if path_direction[j] == "u" # shift the x and y into the appropriate way
                int_y = y.to_i - 1
                y = int_y.to_s
              elsif path_direction[j] == "d"
                int_y = y.to_i + 1
                y = int_y.to_s
              elsif path_direction[j] == "l"
                int_x = x.to_i - 1
                x = int_x.to_s
              elsif path_direction[j] == "r"
                int_x = x.to_i + 1
                x = int_x.to_s
              end
          else
          valid = 0 # if the path runs into a wall, then the path is not valid
        end
        path_arr << "#{x},#{y}"
      end
      if path_length <= 0 and check == 0
        valid = 0
      end
        hash [path_name] = path_arr
        if valid == 1 
          formatted = "%10.4f" % weight_sum
          formatted = formatted + " " + path_name
          result << formatted
      end
    end
    if type == "print"
      shortest_path = result.sort[0] # the shortest path will be sorted to the top
      if shortest_path != nil
        regex =  shortest_path[/^[\s]+[\d+\W]*/] # use regex to extract the name of the path
        shortest_path.slice!(regex.to_s)
      end
      
      if shortest_path != nil and hash[shortest_path].include? start_coord # checks to see if path contains start coord
        match_start = 1
      else
        match_start = 0
      end
      if shortest_path != nil and hash[shortest_path].include? end_coord # checks to see if path contains end coord
        match_end = 1
      else
        match_end = 0
      end
    else
      if result.empty? 
        return "none"
      end
      return result.sort
    end
  end
end
 
if type == "print"
  filler = ""
  first_last_line = 0
  cell_or_line = 0
  print_length = (header[0].to_i * 2) # size of the maze will be the given size (i.e 4) * 2
  x = 0
  y = 0
  down = []
  right = []
  for j in 0..print_length do # j = row
    coord = "#{x},#{y}"
    dir = direction_hash[coord]
    for i in 0..print_length do # i = cols
      if j == 0 or j == print_length # If it's first or last line, print out line of +-+-+...
        if i % 2 == 0
          filler = filler + "+"
        else
          filler = filler + "-"
        end    
      else
        if i == 0 or i == print_length # print borders of maze
          if j % 2 == 1
            filler = filler + "|"
          else
            filler = filler + "+"
          end
        else # being at else means current x,y is not a border of maze
          if j % 2 == 1 # if j%2 == 1 that means it is either a cell or a wall, not a +-+-+ line
            if i % 2 == 1 # if i % 2 == 1, then that means it cannot be a wall and it is a cell. i % 2 == 0 signifies either a wall or an empty space
              if coord == start_coord # check if the path contains end/start coord
                if match_start == 1
                  filler = filler + "S" 
                else
                  filler = filler + "s"
                end
              elsif coord == end_coord
                if match_end == 1
                  filler = filler + "E" 
                else
                  filler = filler + "e" 
                end
              else
                if hash[shortest_path] != nil and hash[shortest_path].include? coord # if there is a shortest path, use *, else use spaces

                  filler = filler + "*" 
                else
                  filler = filler + " " 
                end
              end
              
              if direction_hash[coord] != nil and direction_hash[coord].include? "d" # make an array of which cells should or shouldn't have a wall below [1 0 1 1] means the 2nd cell has a wall 
                down << 1
              else
                down << 0
              end
              
              if direction_hash[coord] != nil and direction_hash[coord].include? "r" # similar for right
                right << 1
              else
                right << 0
              end

              if x == header[0].to_i-1 # prevents the x from going larger than the size
                x = 0
              else
                x += 1
              end
              coord = "#{x},#{y}"
              else
                if right.length > 0 #placing the necessary walls for the right side of a cell
                  if right.shift() == 1
                    filler = filler +  " "
                  else
                    filler = filler +  "|"
                    
                  end
                end
              end
          else
           
            if i % 2 == 0 # deals with the bottom side of the cell
              filler = filler +  "+"
            else
              if down.length > 0
                if down.shift() == 1
                  filler = filler +  " "
                else
                filler = filler +  "-"
                end
              else
                filler = filler +  "-"
                down.shift
              end
              
            end
          end      
        end
      end
    end
    right.shift
    if j % 2 == 1 
      if y == header[0].to_i-1 # prevents the y from going over
        y = 0
      else
        if j != 0
          y += 1
        end
      end
    end  
    coord = "#{x},#{y}"
    filler = filler + "\n"
    
  end
  filler = filler.chomp
  return filler
end

if type == "distance" or type == "solve"
  max_dist = header[0].to_i * header[0].to_i-1
  x = header[1] # x and y are the starting coords
  y = header[2]
  start = []
  start << "#{x},#{y}"
  coord = "#{x},#{y}"
  dist = 0
  map = {dist => start} # map hash will have the distance and the cooresponding coords. Starts wtih 0 and the starting coord
  not_visited = []
  solve = 0

  for a in 0..header[0].to_i-1 # gets all of the cells possible to make a checklist for if they have been visisted
    for b in 0..header[0].to_i-1
      not_visited << "#{a},#{b}"
    end
  end
  
  for i in 0..max_dist 
    distance = i + 1
    if map.keys.include? i # having a 0 creates 1, 1 creates 2, etc. 
      for j in 0..map[i].length-1 # goes through the hash length which is constatly changing
        current = map[i][j] 
        direction = direction_hash[current]   
        add(current, not_visited, direction, i, map) # puts the next move/distance into the hash
  
      end
    end
  end

  result = ""
  for k in 0..map.keys.length-1
    if map[k].any?
      result = result + "#{k},"
      for o in 0..map[k].length-1
        map[k] = map[k].sort
        result =  result + "(" + map[k][o] + ")" + ","
        if map[k][o] == end_coord and type == "solve" # if the end coord is found inside the hash that means it is solvable 
          return true
      
        end
      end
    end
    result = result.chop
    result = result + "\n"
  end
  result = result.chomp
  if type == "distance"
    return result
  else
    return false # reaching this point means it is not solvable
  end

   
end



end


def add(coord, cells, direction, distance, map)
  cells.delete("#{coord}") # coord has been visited
  distance = distance + 1
  test = map.include? distance # create a new hash for a distance if not already made (since this will be iterated through multiple times)

  if test == false
    map[distance] = []
  end
   
  if direction.length > 1 # if a certain cell can go multiple ways, must go through each direction one by one
    for i in 0..direction.length-1
      new_dir = direction[i]
      if new_dir == "u"
        new_x = coord[0]
        new_y = coord[2].to_i - 1
        new_coord = "#{new_x},#{new_y}"
        if cells.include? new_coord # not visited yet
          map[distance] << new_coord
          cells.delete(new_coord) # removes it from visited array
        end
      elsif new_dir == "d"
        new_x = coord[0]
        new_y = coord[2].to_i + 1
        new_coord = "#{new_x},#{new_y}"
      
        if cells.include? new_coord
          map[distance] << new_coord
          cells.delete(new_coord)
        end
      elsif new_dir == "r"
        new_x = coord[0].to_i  + 1
        new_y = coord[2] 
        new_coord = "#{new_x},#{new_y}"
       
        if cells.include? new_coord
          map[distance] << new_coord
          cells.delete(new_coord)
        end
      else
        new_x = coord[0].to_i  - 1
        new_y = coord[2] 
        new_coord = "#{new_x},#{new_y}"
       
        if cells.include? new_coord
          map[distance] << new_coord
          cells.delete(new_coord)
        end
      end
      
    end
  else
    if direction.include? "u" # does the same thing but for a single direction
      temp_x = coord[0].to_i
      temp_y = coord[2].to_i - 1
      if cells.include? "#{temp_x},#{temp_y}"
        map[distance] << "#{temp_x},#{temp_y}"
        cells.delete("#{temp_x},#{temp_y}")
      end
    end
    if direction.include? "d"
      temp_x = coord[0].to_i
      temp_y = coord[2].to_i + 1
      if cells.include? "#{temp_x},#{temp_y}"
        map[distance] << "#{temp_x},#{temp_y}"
        cells.delete("#{temp_x},#{temp_y}")
      end
    end
    if direction.include? "r"
      temp_x = coord[0].to_i + 1
      temp_y = coord[2].to_i  
      if cells.include? "#{temp_x},#{temp_y}"
        map[distance] << "#{temp_x},#{temp_y}"
        cells.delete("#{temp_x},#{temp_y}")
      end
    end
    if direction.include? "l"
      temp_x = coord[0].to_i - 1
      temp_y = coord[2].to_i 
      if cells.include? "#{temp_x},#{temp_y}"
        map[distance] << "#{temp_x},#{temp_y}"
        cells.delete("#{temp_x},#{temp_y}")
      end
    end
  end
   
end

#----------------------------------
def main(command_name, file_name)
maze_file = open(file_name)

# perform command
case command_name
when "parse"
  parse(maze_file)
when "open"
  open_command(maze_file)
when "bridge"
  bridge(maze_file)
when "sortcells"
  sortcells(maze_file)
when "paths"
  paths(maze_file)
when "distance"
  distance(maze_file)
when "print"
  print(maze_file)
when "solve"
  solve(maze_file)
else
  fail "Invalid command"
end
end
