# Install hook code here
def write_layout(controller_name, new_layout)
  puts "Installing layout files into the controllers..."
  file = File.new("app/controllers/#{controller_name}.rb", "r+")
  arr = []
  arr = file.readlines
  for elem in arr do
    if elem.include? "layout '"
      puts elem
      file.pos = 0
      arr[arr.index(elem)] = "\tlayout '#{new_layout.chomp}'"
      found = true
      next
    end 
  end
  file.rewind
  file.truncate(0)
  if found
    for elem in arr do
      file.puts elem
    end
  end
  file.close
  puts "Done"
end


puts "Please Enter an Administrator Layout name: "
admin_layout = gets
puts "Please Enter a Front-End Layout name: "
primary_layout = gets

write_layout("admin_dynamic_forms_controller", admin_layout)
write_layout("dynamic_form_response_controller", admin_layout)
write_layout("dynamic_forms_controller", primary_layout)
