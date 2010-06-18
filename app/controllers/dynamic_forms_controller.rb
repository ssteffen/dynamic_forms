class DynamicFormsController < ApplicationController
	layout 'primary'
  require 'yaml'
  #ssl_required :display_form, :dining_application
  
  # VALIDATION CHECKING METHODS
  def check_names(object, field1 = nil, field2 = nil, field3 = nil)
     if field1 && field2.nil? && field3.nil?
       if (object[field1].blank?)
         flash[:notice] << ["#{field1} is required.<br />"]
       end
     elsif field1 && field2 && field3.nil?
       if (object[field1].blank? || object[field2].blank?)
         flash[:notice] << ["#{field1} and #{field2} are required.<br />"]
       end
     elsif field1 && field2 && field3
       if (object[field1].blank? || object[field2].blank? || object[field2].blank?)
         flash[:notice] << ["#{field1}, #{field2} and #{field3} are required.<br />"]
       end 
     end
   end


   #checks if empty then splits a single name input into two or three parts.
   def check_and_split_name(object, name, required)
     if object[name].blank?
       if required == true
         flash[:notice] << ["#{name} is required.<br />"]
       end
     else
       split_name = object[name].split
       if !(split_name.length == 2 || split_name.length == 3 || split_name.length == 4)
         flash[:notice] << ["A valid #{name} is required. Must at least contain first, last.<br />"]
       end
     end
   end    


   #Checks for a valid set of addresses
   def check_address(object, street, city, zip)
     if(object[street].blank? || object[city].blank? || object[zip].blank?)
       flash[:notice] << ["#{street}, #{city}, and #{zip} are required.<br />"]
     elsif !(object[zip].size == 5 || object[zip].size == 10)
       flash[:notice] << ["Valid #{zip} is required.<br />"]
     end
   end

   def check_zip(object, zip, required)
     if object[zip].blank?
       if required == true
         flash[:notice] << ["#{zip} is required.<br />"]
       end
     elsif !(object[zip].size == 5 || object[zip].size == 10)
       flash[:notice] << ["Valid #{zip} is required.<br />"]
     end
   end

   def check_date(object, date, name)
     if (object[date] !~ /\d{2}\/\d{2}\/\d{2}/)
       flash[:notice] << ['Valid ' + name + ' in the form of (mm/dd/yy) is required<br />']
     end
   end

   def check_email(object, att, required)
     if(object[att].blank? || !(object[att] =~ RFC822::EmailAddress))
       flash[:notice] << ["A valid #{att} is required.<br />"]
     end
   end

   def check_email_confirm(object, att, att2, required)
     if(object[att].blank? || !(object[att] =~ RFC822::EmailAddress))
       flash[:notice] << ['Please enter a valid email address and confirm it.<br />']
     end
   end

   def check_phone(object, att, required)
     if(object[att].blank?)
       if required == true
         flash[:notice] << ["Please enter a valid #{att}.<br />"]
       end
     else
       phone_dig = object[att].gsub(/[^0-9]/,'')
       if(phone_dig.size != 10)
         flash[:notice] << ["Please enter a valid #{att}.<br />"]
       end
     end
   end

   def check_dawgtag(object, dawgtag, required)
     if(object[dawgtag].blank?)
       if required == true
         flash[:notice] << ["#{dawgtag} is required.<br />"]
       end
     elsif object[dawgtag].size != 9
       flash[:notice] << ["A valid #{dawgtag} is required.<br />"]
     end
   end
   
   def check_date_text_format(object, textfield, required)
     if object[textfield].blank?
       if required == true
         flash[:notice] << ["#{textfield} is required.<br />"]
       end
     else 
       unless object[textfield] =~ /[0-9]{2}\/[0-9]{2}\/[0-9]{4}/
         flash[:notice] << ["#{textfield} is not in the correct format. Make sure it is mm/dd/yyyy. <br />"]
       end
     end
   end

   def check_agree(object, agree)
     if(object[agree] != '1')
       flash[:notice] << ['You must agree to the policy. <br />']
     end
   end

   def check_field(object, att, required)
     logger.info "In Check Field"
     if required == true
       if(object[att].blank?)
        flash[:notice] << ["#{att} field cannot be blank.<br />"]
       end
     end 
   end

   def check_plain(object, att, required)
     if object[att].blank?
       if required == true
         flash[:notice] << ["#{att} is required.<br />"]
       end
     elsif(object[att] =~ /[^a-zA-Z .,'":]/)
       flash[:notice] << ["#{att} must not contain numbers or special characters.<br />"]
     end 
   end
   # END VALIDATION CHECKING METHODS
   
  #BEGIN MAIN ACTIONS
  def index
    @form_list = DynamicForm.find(:all)
  end
  
  def display_form
    @form = DynamicForm.find(:first, :conditions => {:title => CGI.unescape(params[:id])})
    fields = YAML.load(@form.fields)
    @fields_array = []
    @fields_array = fields
    for a in @fields_array
      a.each_pair{|k,v| logger.info "#{k}: #{v}"}
      logger.info '---------------------------------'
    end
    if request.get?
      @sub = Hash.new 
    else
      @sub = params[:form]
      flash[:notice] = []
      
      # BEGIN FIELD LOOP
      for field in @fields_array do
        
        name = field[:fields_name].downcase.gsub(' ', '_')
        if @sub.has_key?(field[:fields_name].downcase.gsub(' ', '_'))
          
          # VALIDATION CHECKING
          if field[:fields_type] == "Text Field"
            # Email validation
            if field[:validation_type] == "Email"
              if field[:required_field] == "Yes"
                check_email(@sub, name.to_sym, true)
              else 
                check_email(@sub, name.to_sym, false)
              end   
            # Phone Validation  
            elsif field[:validation_type] == "Phone Number"
              if field[:required_field] == "Yes"
                check_phone(@sub, name.to_sym, true)
              else
                check_phone(@sub, name.to_sym, false)
              end 
            # Zip Validation 
            elsif field[:validation_type] == "Zip Code"
              if field[:required_field] == "Yes"
                check_zip(@sub, name.to_sym, true)
              else
                check_zip(@sub, name.to_sym, false)
              end
            # Dawgtag Validation
            elsif field[:validation_type] == "Dawgtag"
              if field[:required_field] == "Yes"
                check_dawgtag(@sub, name.to_sym, true)
              else
                check_dawgtag(@sub, name.to_sym, false)
              end
            # Plain Characters Validation
            elsif field[:validation_type] == "Plain"
              if field[:required_field] == "Yes"
                check_plain(@sub, name.to_sym, true)
              else
                check_plain(@sub, name.to_sym, false)
              end
            # Default Validation
            elsif field[:validation_type] == "Default"
              if field[:required_field]
                check_field(@sub, name.to_sym, true)
              else
                check_field(@sub, name.to_sym, false)
              end
            end
          else
            # Other Validation 
            if field[:required_field] == "Yes"
              check_field(@sub, name.to_sym, true)
            end
          end
          
        end
        #Check for term agreements
        if field[:fields_type] == "Accept Terms"
          logger.info "TERMS AND CONDITIONS: #{@sub[name.to_sym]}"
          if @sub[name.to_sym].nil? || @sub[name.to_sym] != "Accept"
            flash[:notice] << ['You must accept the terms and conditions of the form.<br />']
          end
        end
        #Check for Date Select
        if field[:fields_type] == "Date Select" || field[:fields_type] == "DateTime Select" || field[:fields_type] == "Time Select"
          @sub[name.to_sym] = Hash.new
          @sub[name.to_sym] = params[name.to_sym]
          #logger.info "Name: #{name.to_sym}"
          #logger.info "Params: #{params[name.to_sym].to_s}"
        end
      end 
      @sub.each_pair{|k,v| logger.info "#{k}: #{v}"}
      logger.info "---------------------------------"
      # END FIELD LOOP

      if flash[:notice].empty?
        yaml_string = @sub.to_yaml
        response = DynamicFormResponse.new(:response => yaml_string, :dynamic_form_id => @form.id)
        if response.save
          unless @form.email_notification_address.blank?
            Notifier.deliver_new_forms_notification(@form, response.id, @form.email_notification_content)
          end
          flash[:notice] << [@form.success_message + "<br />"]
        else
          flash[:notice] << [@form.failure_message + "<br />There was a problem saving your submission. Please try again later.<br />"]
        end
      else
        flash[:notice].insert(0, @form.failure_message + "<br />")
      end
    end
  end
  # End of Dynamic "display_form" method.
  
end  

