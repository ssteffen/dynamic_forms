class CreateDynamicForms < ActiveRecord::Migration
  def self.up #Create Table for form data
    create_table :dynamic_forms, :primary_key => :id, :force => true do |t|
      t.string :title
      t.string :stub
      t.text :prepend_content
      t.text :append_content
      t.text :fields
      t.text :success_message
      t.text :failure_message
      t.boolean :enabled
      t.string :email_notification_address
      t.text :email_notification_content
      t.datetime :available_at
      t.datetime :unavailable_at
      t.text :unavailable_message
      t.datetime :updated_at
    end
    
    #Create table to store user responses to forms
    create_table :dynamic_form_responses, :primary_key => :id, :force => true do |t|
      t.text :response
      t.integer :dynamic_form_id
      t.timestamps
    end
  end

  def self.down
    drop_table :dynamic_form_responses
    drop_table :dynamic_forms
  end
end
