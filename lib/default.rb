# encoding: utf-8

=begin
Copyright Daniel Meißner <dm@3st.be>, 2012

This file is part of FreifunkKBUInfoPage.

FreifunkKBUInfoPage is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FreifunkKBUInfoPage is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FreifunkKBUInfoPage. If not, see <http://www.gnu.org/licenses/>.
=end

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

def create_index
  File.open(Pathname.pwd + "content/start_page.haml", "w") do |f|
    f.puts "-# automatically generated copy of index.haml"
    File.open(Pathname.pwd + 'content/index.haml').each_line do |line|
      f << line
    end
  end
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

begin
  # TODO: function defined in lib/default.rb
  create_index
end
