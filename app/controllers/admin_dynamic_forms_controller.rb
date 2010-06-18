class AdminDynamicFormsController < ApplicationController
  #before_filter :check_authentication, :check_authentication
  protect_from_forgery :except => [:add_fields, :update_list]
	layout 'secondary'
  
  def index
    redirect_to :action => 'list'
  end
  
  def list
    @forms = DynamicForm.find(:all)
  end
  
  def new
    @form = DynamicForm.new
    @fields = Hash.new
    @int_fields = Hash.new
    @count = 0
    session[:form_id] = nil
  end
  
  def create
  end
  
  def edit
    @form = DynamicForm.find(params[:id])
    @count = 0
    session[:form_id] = @form.id
  end
  
  def destroy
    session[:form_id] = nil
    form = DynamicForm.find(params[:id])
    form.destroy
    redirect_to :action => 'list'
  end
  
  def update
  end
  
  #This method shows the list of fields in form
  def add_fields
    session[:count] = 0
    @fields = []
    if params[:dynamic_form] #Get information from form before
      logger.info "Params[:form]"
      form_hash = params[:dynamic_form]
      if(params[:id]) #If Editing
        logger.info "Editing"
        form = DynamicForm.find(params[:id])
        form.update_attributes(form_hash)
        session[:form_id] = form.id
        logger.info "FIELDS: #{form.fields}"
        if form.fields == "To be Filled"
          @message = "<p>No fields</p>"
        else
           @fields = YAML::load(form.fields)
        end
      else #Creating New Form
        logger.info "Creating a new form: #{form_hash.to_s}"
        form = DynamicForm.create(form_hash)
        form.save!
        session[:form_id] = form.id
      end
    else #Handle field updating and list creation
      form = DynamicForm.find(session[:form_id])
      #logger.info "Fields Hash: #{YAML::load(form.fields).to_s}"
      unless form.fields == "To be Filled"
        @fields = YAML::load(form.fields)
      end      
    end
  end
  
  #This method handles the creating of fields in the form object
  def add_field
    if request.get?
      @info = Hash.new
      @field_hash = Hash.new
      session[:count] = 1
    else
      @fields = []
      @field_hash = Hash.new
      session[:field_hash] = @field_hash
      form = DynamicForm.find(session[:form_id])
      @info = params[:info]
      if form.fields == "To be Filled"
        logger.info 'FIELDS TO BE FILLED'
        form.fields = {}
      else
        @fields = YAML::load(form.fields)
        logger.info "Loading YAML {line 92}"
      end     
      @fields << @info
      form.fields = @fields.to_yaml
      form.save
      logger.info "Returned: #{@info}"
      redirect_to :action => 'add_fields'
    end
  end
  
  def edit_field
    if request.get?
      @field_hash = Hash.new
      @fields = []
      @field_name = CGI.unescape(params[:id])  
      session[:field_name] = @field_name
      form = DynamicForm.find(session[:form_id])
      unless form.fields == "To be Filled"
        @fields = YAML::load(form.fields)
        for field in @fields
          if field[:fields_name] == @field_name
            @field_hash = field
            session[:field_hash] = field
            if field[:fields_type] == "Select Box"
              @field = field.sort_by {|x| x[0][19 .. -1].to_i}
            elsif field[:fields_type] == "Check Box"
              @field = field.sort_by {|x| x[0][17 .. -1].to_i}
            elsif field[:fields_type] == "Radio Button"
              @field = field.sort_by {|x| x[0][21 .. -1].to_i}
            else
              @field = field.sort
            end
            #logger.info "FIELD O: #{@field[0][0]}"
            logger.info "Field: #{@field.to_s}"
          end
        end
      end
      @f = @field_hash[:fields_type].downcase
      #logger.info "FIELD HASH: #{@field_hash.to_s}"
    else
      @fields = []
      @field_hash = Hash.new
      form = DynamicForm.find(session[:form_id])
      @field_name = session[:field_name]
      session[:field_name] = nil
      unless form.fields == "To be Filled"
        @fields = YAML::load(form.fields)
        logger.info "YAML: #{@fields.to_s}"
        for field in @fields
          if field[:fields_name] == @field_name
            @field_hash = field
            logger.info "Field: #{@field_hash.to_s}"
            @edit = params[:info]
            ind = @fields.index(field)
            logger.info "FIELD: #{field.to_s}"
            @fields[ind] = @edit
            form.fields = @fields.to_yaml
            logger.info "YAML: #{@fields.to_yaml}"
            form.save
            redirect_to :action => 'add_fields' and return
          end
        end
        #if @field_hash.empty?
        #  logger.info "Field not found"
        #  redirect_to :action => 'add_fields'
        #end
      end
    end
  end
  
  #Deletes individual fields
  def delete_field
    name = CGI.unescape(params[:id])
    form = DynamicForm.find(session[:form_id])
    fields = YAML::load(form.fields)
    for hash in fields do
      if hash[:fields_name] == name
        fields.delete(hash)
        session[:field_hash] = nil
      end
    end
    if fields.empty?
      form.fields = "To be Filled"
    else
      form.fields = fields.to_yaml
    end
    form.save
    flash[:notice] = "Field Deleted."
    redirect_to :action => 'add_fields'
  end
  
  def delete_all_fields
    form = DynamicForm.find(session[:form_id])
    form.fields = "To be Filled"
    form.save!
    flash[:notice] = "All Fields Deleted."
    redirect_to :action => 'add_fields'
  end
  
  def change_type(type = nil)
    #@radio_buttons = session[:count]
    @field_hash = Hash.new
    @field_hash = session[:field_hash]
    @type = params[:type]
    if(type)
      @type = type
    end
    @type_path = case @type
      when "Text Field" then "admin_dynamic_forms/field_partials/text_field_options.html.erb"
      when "Text Area" then "admin_dynamic_forms/field_partials/text_area_options.html.erb"
      when "Check Box" then "admin_dynamic_forms/field_partials/check_box_options.html.erb"
      when "Radio Button" then "admin_dynamic_forms/field_partials/radio_button_options.html.erb"
      when "Select Box" then "admin_dynamic_forms/field_partials/select_box_options.html.erb"
      when "Numbered Select Box" then "admin_dynamic_forms/field_partials/select_box_options.html.erb"
      when "Date Select" then "admin_dynamic_forms/field_partials/date_select_options.html.erb"
      when "Time Select" then "admin_dynamic_forms/field_partials/time_select_options.html.erb"
      when "DateTime Select" then "admin_dynamic_forms/field_partials/datetime_select_options.html.erb"
      when "State Select" then "admin_dynamic_forms/field_partials/state_select_options.html.erb"
      when "Country Select" then "admin_dynamic_forms/field_partials/country_select_options.html.erb"
      when "Paragraph" then "admin_dynamic_forms/field_partials/paragraph_options.html.erb"
      when "Accept Terms" then "admin_dynamic_forms/field_partials/accept_terms.html.erb"
      else "admin_dynamic_forms/field_partials/blank.html.erb"
    end
  end
  
  def updated_list
    logger.info "In Updated List"
  end
  
  
  
  ################################################
  #The following methods go together for
  # radio buttons, select boxes, and check boxes
  # to dynamically create fields, there
  # is a lot of duplicated code, but the seperate
  # methods were necessary for the partials.
  ###############################################
  def add_select_option()
    session[:count] += 1
  end
  
  def remove_select_option
    if params[:id]
      @count = params[:id]
    end
  end
  
  def add_checkbox_options()
    session[:count] += 1
  end
  
  def remove_checkbox_option
    if params[:id]
      @count = params[:id]
    end
  end
  
  def add_radio_options()
    session[:count] += 1
  end
  
  def remove_radio_option
    if params[:id]
      @count = params[:id]
    end
  end
    
  ##########################
  #END Dynamic field methods.  
  
end

