require "spec_helper"

describe "Feedback" do

  before :all do
    @feedback = Alfred::Feedback.new

    @item_elements = %w{title subtitle icon}
    @item_attributes = %w{uid arg autocomplete}
  end
  it "should create a basic XML response" do
    @feedback.add_item(:uid          => "uid"          ,
                       :arg          => "arg"          ,
                       :autocomplete => "autocomplete" ,
                       :title        => "Title"        ,
                       :subtitle     => "Subtitle")

    xml_data = <<-END.strip_heredoc
      <?xml version="1.0"?>
      <items>
        <item valid="yes" arg="arg" autocomplete="autocomplete" uid="uid">
          <title>Title</title>
          <subtitle>Subtitle</subtitle>
          <icon>icon.png</icon>
        </item>
      </items>
    END

    expected_xml = REXML::Document.new(xml_data)
    feedback_xml = REXML::Document.new(@feedback.to_xml)

    expected_item = expected_xml.get_elements('/items/item')[0]
    feedback_item = feedback_xml.get_elements('/items/item')[0]

    @item_elements.each { |i|
      expected_item.elements[i].text.should == feedback_item.elements[i].text
    }
    @item_attributes.each { |i|
      expected_item.attributes[i].should == feedback_item.attributes[i]
    }

  end

end
