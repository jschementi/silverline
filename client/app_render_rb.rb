require 'silverlight'

SilverlightApplication.class_eval do
  def start
    eval XAP.get_file_contents("#{params[:rb_to_run]}.rb").to_str
  end
end

SilverlightApplication.new.start
