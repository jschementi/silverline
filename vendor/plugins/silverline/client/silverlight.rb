include System
include System::Windows
require 'lib/helpers/debug'

$PARAMS = {}
Application.current.init_params.collect do |pair|
  $PARAMS[pair.key.to_s.to_sym] = pair.value
end

$DEBUG = $PARAMS[:debug] || false

require 'lib/silverlight_application'