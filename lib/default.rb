# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'nanoc3/data_sources/filesystem_i18n'
require 'psych'
require 'redcloth'
require 'pathname'
require 'fileutils'

include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::XMLSitemap


def copy_index
  index = Pathname.pwd + Pathname.new("content/index.haml")
  FileUtils.cp(index, Pathname.pwd + Pathname.new("content/start_page.haml"))
end

def load_translations
  @translations = {}
  I18n.available_locales.each { |locale| @translations.merge!( locale => Psych.load_file("lib/#{locale}.yml") ) }
end


def normalize_identifier(item, force_locale = nil)
  identifier = if item.children.size > 0 || item.identifier == '/' || item.identifier == "/#{item[:locale]}/"
    item.identifier + 'index.html'
  else
    page = item.identifier
    #page = "/contact" if page =~ /contact/
    #page = "/participation" if page =~ /participation/
    #page = "/nodes" if page =~ /nodes/
    #"#{page}.#{item[:extension]}"
    "#{page}"
  end
  identifier.gsub!(/^\/([en|de]+)/, "/#{force_locale}") if force_locale
  identifier
end

def t(key)
  load_translations unless @translations
  key.split(/\./).inject(@translations[@item[:locale]]) { |result, subkey| result = result[subkey] }
end
