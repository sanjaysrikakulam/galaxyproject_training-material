#!/usr/bin/env ruby
require 'yaml'

current_mapping = YAML.load_file('metadata/shortlinks.yaml')

if not current_mapping.has_key? 'id'
  current_mapping['id'] = {}
end

if not current_mapping.has_key? 'name'
  current_mapping['name'] = {}
end

def is_mapped(tutorial, current_mapping)
  return current_mapping['id'].values.include? tutorial
end

# Discover tutorials
Dir.glob('topics/*/tutorials/*/tutorial.md').each do |tutorial|
  html_path = '/' + tutorial.gsub(/md$/, 'html')
  # If it's not already mapped by a key, add it.
  if not is_mapped(html_path, current_mapping)
    # Generate a short code
    short_code = (current_mapping['id'].length).to_s(16)
    # If the target of this flavour of short code isn't already in here, then add it
    current_mapping['id'][short_code] = html_path
  end

  # Also generate one from topic/tutorial name
  # These are idempotent and safe
  short_code2 = tutorial.split('/')[1..3].join('/').gsub(/\/tutorials/, '')
  current_mapping['name'][short_code2] = '/' + tutorial.gsub(/md$/, 'html')
end

# Discover slides
Dir.glob('topics/*/tutorials/*/slides.html').each do |tutorial|
  html_path = '/' + tutorial
  puts html_path
  # If it's not already mapped by a key, add it.
  if not is_mapped(html_path, current_mapping)
    # Generate a short code
    short_code = (current_mapping['id'].length).to_s(16)
    # If the target of this flavour of short code isn't already in here, then add it
    current_mapping['id'][short_code] = html_path
  end

  # Also generate one from topic/tutorial name
  # These are idempotent and safe
  short_code2 = tutorial.split('/')[1..3].join('/').gsub(/\/tutorials/, '') + '/slides'
  current_mapping['name'][short_code2] = '/' + tutorial.gsub(/md$/, 'html')
end

# Write out the new shortlinks.yaml file
File.open('metadata/shortlinks.yaml', 'w') do |file|
  file.write(current_mapping.to_yaml)
end
