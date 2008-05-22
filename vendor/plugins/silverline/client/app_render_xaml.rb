require 'silverlight'

options = {:name => $PARAMS[:xaml_to_render]}
options[:type] = Inflection.constantize($PARAMS[:xaml_type]) unless $PARAMS[:xaml_type].nil?

SilverlightApplication.use_xaml options
