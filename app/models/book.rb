require 'tesseract'
require 'RMagick'

class Book < ActiveRecord::Base
  has_attached_file :attachment
  has_many :words
  validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/


  def generate_words
      include Magick
    image_path = attachment.path

    e = Tesseract::Engine.new {|e|
      e.language  = lang.to_sym
      e.blacklist = '|'
    }

    boxes = []
    ocr_words = []
    e.each_word_for(image_path) do |word|
     boxes << word.bounding_box
     ocr_words << text_for(word)
    end

    image = Image.read(image_path).first

    boxes.each_with_index do |box, i|
      b = image.crop(box.x, box.y, box.width, box.height);
      f = b.write("#{Rails.root}/public/word#{i}.png")
      word = words.build ocr_text: ocr_text[i]
      word.image = open f.filename
      word.save
    end
  end
end
