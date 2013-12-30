require 'nokogiri'
require 'open-uri'


class Country

  include Comparable

  @@all = {}

  attr_reader :name
  attr_accessor :flag
  attr_accessor :coat_of_arms
  attr_accessor :seal

  def initialize(name)
    @name = name
    @@all[name] = self
  end

  def to_s
    data = ["Name: #{name}"]
    data << ["Flag: #{flag || 'None'}"]
    data << ["Seal: #{coat_of_arms}"] if seal
    data << ["Coat of Arms: #{coat_of_arms}"] if coat_of_arms
    data.join("\n")
  end

  def <=>(other)
    name <=> other.name
  end

  def self.[](name)
    @@all[name]
  end

  def self.all
    @@all.values.sort
  end

  def self.each(&block)
    all.each(&block)
  end

  def self.select(&block)
    all.select(&block)
  end

  def self.names
    all.map(&:names)
  end

  def self.flagless
    select { |c| c.flag.nil? }
  end

end


def html
  File.open('national_insignia', 'w') { |f| f.write(open('http://commons.wikimedia.org/wiki/National_insignia').read) } unless File.exists?('national_insignia')
  @html ||= Nokogiri::HTML(File.read('national_insignia'))
end

html.css('h3 > .mw-headline').map { |x| Country.new(x.text) }


##mw-content-text > h3:nth-child(6)

##Abkhazia > a:nth-child(1)
#ul.gallery:nth-child(7) > li:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > a:nth-child(1) > img:nth-child(1)

#<h3><span class="mw-headline" id="Abkhazia"><a href="/wiki/Abkhazia" title="Abkhazia" class="mw-redirect">Abkhazia</a></span></h3>

#puts data.size
#countries.each { |x| puts x.inspect }

def match_flag(flags, country, name)
  name = name.downcase
  potential = flags.select { |f| URI.unescape(f).downcase.include?(name) }.sort { |a, b| a.size <=> b.size }
  if potential.size == 1
    flags.delete(potential.first)
    country.flag = potential.first
  end
end

svgs = html.css('.image').map { |x| x['href'] }.select { |x| x[-4..-1] == '.svg' }
#flags = svgs.select { |x| x[0..18] == '/wiki/File:Flag_of_' }.uniq
flags = svgs.select { |x| x.to_s.include?('flag') }.uniq
svgs -= flags
coat_of_arms = svgs.select { |x| x.downcase.include?('coat_of_arms_of') }.uniq
#coat_of_arms = svgs.select { |x| x.downcase.include?('coats_of_arms_of_') }.uniq
#emblem = svgs.select { |x| x.to_s.downcase.include?('emblem') }.uniq
#
#seals = svgs.select { |x| x.downcase.include?('coat_of_arms_of') }.uniq

svgs -= coat_of_arms

puts svgs
exit

2.times do
  Country.flagless.each do |country|
    match_flag(flags, country, country.name.gsub(' ', '_').downcase + '.svg')
  end
end

Country.flagless.each do |country|
  match_flag(flags, country, country.name.gsub(' ', '_').gsub('é', 'e').gsub('ã', 'a').gsub('í', 'i').downcase)
end

match_flag(flags, Country['British Falkland Islands'], 'falkland')
match_flag(flags, Country['China'], 'People\'s_Republic_of_China')
match_flag(flags, Country['Taiwan (Republic of China)'], 'Republic_of_China')
Country['Réunion'].flag = Country['France'].flag.dup


#flags.each { |x| puts x }

#puts coat_of_arms
#puts svgs