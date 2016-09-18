require 'silverlight'

#TODO: there's something really scary about this ...

properties = {}
properties[:type] = Inflection.constantize($PARAMS[:xaml_type]) unless $PARAMS[:xaml_type].nil?
SilverlightApplication.new.render :partial => $PARAMS[:xaml_to_render], :properties => properties

#options = {:name => $PARAMS[:xaml_to_render]}
#options[:type] = Inflection.constantize($PARAMS[:xaml_type]) unless $PARAMS[:xaml_type].nil?

#SilverlightApplication.use_xaml options