module XAP
  include System
  include System::IO
  include System::Windows::Resources
  
  def self.get_file_contents(relative_path_or_uri)
    if relative_path_or_uri.class == String || relative_path_or_uri.class == ClrString
      get_file_contents(Uri.new(normalize_path(relative_path_or_uri), UriKind.relative))
    elsif relative_path_or_uri.class == Uri
      file = get_file(relative_path_or_uri)
      return nil if file.nil?
      sr = StreamReader.new(file)
      result = sr.read_to_end
      sr.close()
      return result
    end
  end
  
  def self.get_file(relative_path_or_uri)
    if relative_path_or_uri.class == String || relative_path_or_uri.class == ClrString
      get_file(Uri.new(normalize_path(relative_path_or_uri), UriKind.relative))
    elsif relative_path_or_uri.class == Uri
      sri = Application.get_resource_stream(relative_path_or_uri)
      return nil if sri.nil?
      sri.stream
    end
  end
  
  private
  
    def self.normalize_path(path)
      # files are stores in the XAP using forward slashes
      path.to_clr_string.replace(Path.directory_separator_char.to_string, "/").to_s
    end
  
end
