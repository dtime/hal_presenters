require 'spec_helper'
describe HalPresenters::Helpers::Rootify do
  let(:hash){
    {
      "_links" => {
        "href" => "/foo",
        "href-template" => "/foo",
        "nested" => {"href" => "/bar"},
        "nested_template" => {"href-template" => "/bar"},
        "deep_nested" => {"href" => {"href" => "/quux"}},
        "deep_nested_template" => {"href" => {"href-template" => "/quux"}},
        "relative" => {"href" => "safe"},
        "relative_template" => {"href-template" => "safe"},
        "http" => {"href" => "http://safe"},
        "http_template" => {"href-template" => "http://safe"},
        "not_href" => "/safe"
      },
      "has_href_val" => "href",
      "has_href_template_val" => "href",
      "embedded" => {"href-template" => '/baz', "href" => "/baz", "_links" => {}}
    }
  }
  let(:presenter){
    me = DumbPresenter.new(nil, root: 'my_root')
    me.extend(HalPresenters::Helpers::Rootify::InstanceMethods)
    me
  }
  describe 'absolutify' do
    let(:subject){
      presenter.absolutify(hash)
    }
    it 'finds shallow links' do
      subject["_links"]["href"].should == "my_root/foo"
    end
    it 'ignores http' do
      subject["_links"]["http"]["href"].should == "http://safe"
    end
    it 'ignores relative' do
      subject["_links"]["relative"]["href"].should == "safe"
    end
    it 'ignores href-ish' do
      subject["_links"]["not_href"].should == "/safe"
    end
    it 'ignores vals' do
      subject["has_href_val"].should == "href"
    end
    it 'ignores vals' do
      subject["has_href_val"].should == "href"
      subject["has_href_template_val"].should == "href"
    end
    it 'finds very deep' do
      subject["_links"]["deep_nested"]["href"]["href"].should == "my_root/quux"
    end
    it 'finds deep elsewhere' do
      subject["embedded"]["href"].should == "my_root/baz"
    end
    it 'finds deep links' do
      subject["_links"]["nested"]["href"].should == "my_root/bar"
    end
  end
  describe 'rootify in non-full' do
    subject { presenter.rootify(hash, :embedded) }
    it 'adds dtime:root' do
      subject["_links"].should_not have_key("dtime:root")
    end
  end
  describe 'rootify' do
    subject { presenter.rootify(hash, :full) }
    it 'adds dtime:root' do
      subject["_links"].should have_key("dtime:root")
    end
    it 'doesn\'t do dtime:root in nested' do
      subject["embedded"]["_links"].should_not have_key("dtime:root")
    end
  end
end
