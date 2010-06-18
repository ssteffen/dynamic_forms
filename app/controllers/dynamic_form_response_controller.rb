class DynamicFormResponseController < ApplicationController
	layout 'secondary'
  require 'yaml'
  
  def index
    @forms = DynamicForm.find(:all)
  end
  
  def view_submissions
    @form = DynamicForm.find(params[:id])
    @sub_array = []
    @hash = Hash.new
    @results = @form.dynamic_form_responses
  end
  
  def delete_result
    form_result = DynamicFormResponse.find(params[:id])
    form_id = form_result.form_id
    if form_result.delete
      flash[:notice] = "Result successfully deleted."
    else
      flash[:notice] = "Error occured, result not deleted."
    end
    redirect_to :action => 'view_submissions', :id => form_id
  end
  
  def view_result
    @form_result = DynamicFormResponse.find(params[:id])
    @form = DynamicForm.find(@form_result.dynamic_form_id)
    @results_hash = YAML.load(@form_result.response)
    @fields = YAML.load(@form.fields)   
    @results = []
    @name = ""
    for result in @results_hash
      if result[0] =~ /(name)/
        @name = result[1]
        break
      end 
    end
    @checkbox_hash = Hash.new
    for field in @fields
      @results_hash.each_pair{|k,v| logger.info "KEY: #{k}, VALUE: #{v}"}
      for result in @results_hash
        #logger.info "RESULT [0]: #{result[0].gsub('_', ' ')} ==== Fields_Name: #{field[:fields_name].downcase}"
        #logger.info "2nd try: #{result[0].gsub('_', ' ').gsub(field[:fields_name].downcase, '').downcase} ========= #{result[1].downcase}"
        if result[1].is_a?(Hash) && (result[1].has_key?("day") || result[1].has_key?("hour")) && (result[0].gsub('_', ' ') == (field[:fields_name]).downcase)
          @second_hash = Hash.new
          @second_hash = result
          if field[:fields_type] == "Date Select"
            @results << [result[0], "#{result[1][:month]}/#{result[1][:day]}/#{result[1][:year]}"]
          elsif field[:fields_type] == "DateTime Select"
            @results << [result[0], "#{result[1][:hour]}:#{result[1][:minute]} on #{result[1][:month]}/#{result[1][:day]}/#{result[1][:year]}"]
          elsif field[:fields_type] == "Time Select"
            @results << [result[0], "#{result[1][:hour]}:#{result[1][:minute]}"]
          end
        else
          unless result[1].is_a?(Hash)
            logger.info "Result[1] is not a hash"
            if (result[0].gsub('_', ' ') == (field[:fields_name]).downcase) || 
              (result[0].gsub('_', ' ').gsub(field[:fields_name].downcase, '').downcase == ' ' + result[1].downcase)
              if(field[:fields_type] == "Check Box")
                @results << [field[:fields_name], "Check Box"]
                if @checkbox_hash[field[:fields_name].to_sym]
                  @checkbox_hash[field[:fields_name].to_sym] << [result[1]]
                else
                  @checkbox_hash[field[:fields_name].to_sym] = [result[1]]
                end
              else
                @results << result
              end
            end
          end
        end
      end
    end
    #logger.info "RESULTS #{@results.to_s}"
  end
    
end
