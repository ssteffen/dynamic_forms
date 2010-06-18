class DynamicForm < ActiveRecord::Base
  validates_presence_of :title, :stub, :fields, :success_message, :failure_message
  #validates_inclusion_of :require_ssl, :in => [true, false], :message => "must be yes or no"
  validates_format_of :email_notification_address, :with => RFC822::EmailAddress, :allow_blank => true 
  has_many :dynamic_form_responses
  
  def before_validation
    if self.fields.blank?
      self.fields = "To be Filled"
    end
  end
end

